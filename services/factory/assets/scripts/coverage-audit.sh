#!/bin/sh
# coverage-audit.sh
# Deterministic coverage scan of a project surface (spec-coverage-scan).
# Reads <root>/surface.tsv and the agent set of the project, writes one
# report to the standard output, and exits 0, 1, or 2. Writes no file.
# The declared tool set is POSIX sh, awk, sed, grep, sort, and find.
# The script uses no jq and no yq.
#
# Report shape:
#   coverage: <entry count> entries, <unowned count> unowned author paths
#   <path><TAB><copy-mode><TAB><nearest-role><TAB><proposed-role>
#   proposal: <role-name>
#   - <ownership pattern>
#
# Exit codes: 0 no unowned author path, 1 one or more, 2 an input error.
set -eu
LC_ALL=C
export LC_ALL

TAB=$(printf '\t')
ROOT=${1:-.}
ROOT=${ROOT%/}
[ -n "$ROOT" ] || ROOT=/
DECL="$ROOT/surface.tsv"

# The shipped role names (spec-repository-role). A proposed name that equals a
# shipped role name takes the suffix `-local` (spec-proposed-role, C-CA16).
SHIPPED_ROLES="artifact-master requirement-expert solution-expert artifact-release-expert factory-expert designer-expert repository-expert"

err() {
  printf 'coverage: error: %s\n' "$1" >&2
  exit 2
}

# ---------------------------------------------------------------------------
# The JSONC / JSON parse (adr-agent-definition-read, C-FCA-02-03).
# One awk program normalizes the document and parses the token stream.
# mode `doc`: the top-level `permissions` rules (id `*`) and the
#   `agents.<id>.permissions` rules.
# mode `rules`: one `permissions` array of a file frontmatter.
# Each emitted line: kind TAB doc TAB seq TAB id TAB action TAB resource TAB effect
# ---------------------------------------------------------------------------
AWK_PARSE='
function die(msg) { print "coverage: error: " msg > "/dev/stderr"; exit 1 }
function tokenize(text,   len,i,c,d,j,s) {
  ntok=0; len=length(text); i=1
  while (i<=len) {
    c=substr(text,i,1)
    if (c==" " || c=="\t" || c=="\n" || c=="\r") { i++; continue }
    if (c=="\"") {
      s="\""; j=i+1
      while (j<=len) {
        d=substr(text,j,1)
        if (d=="\\") { s=s d substr(text,j+1,1); j+=2; continue }
        s=s d
        if (d=="\"") { j++; break }
        j++
      }
      tok[++ntok]=s; i=j; continue
    }
    if (c=="{" || c=="}" || c=="[" || c=="]" || c==":" || c==",") { tok[++ntok]=c; i++; continue }
    j=i
    while (j<=len) {
      d=substr(text,j,1)
      if (d==" " || d=="\t" || d=="\n" || d=="\r" || d=="," || d=="{" || d=="}" || d=="[" || d=="]" || d==":") break
      j++
    }
    tok[++ntok]=substr(text,i,j-i); i=j
  }
}
function isstr(t) { return substr(t,1,1)=="\"" }
function unq(t) { if (isstr(t)) return substr(t,2,length(t)-2); return t }
function peek() { return tok[pos+1] }
function adv() { pos++; return tok[pos] }
function skipValue(   t) {
  t=peek()
  if (t=="{") { skipObject(); return }
  if (t=="[") { skipArray(); return }
  adv()
}
function skipObject(   t) {
  adv()
  if (peek()=="}") { adv(); return }
  while (1) {
    adv(); adv(); skipValue()
    t=adv()
    if (t=="}") return
  }
}
function skipArray(   t) {
  adv()
  if (peek()=="]") { adv(); return }
  while (1) {
    skipValue()
    t=adv()
    if (t=="]") return
  }
}
function emit(id,   k) {
  k=kind
  if (k=="") k=0
  print k "\t" di "\t" ++seq "\t" id "\t" ruleAction "\t" ruleResource "\t" ruleEffect
}
function parseRule(   t,key,v) {
  adv()
  ruleAction=""; ruleResource=""; ruleEffect=""
  if (peek()=="}") { adv(); return }
  while (1) {
    key=unq(adv()); adv()
    v=peek()
    if (isstr(v)) {
      if (key=="action") ruleAction=unq(v)
      else if (key=="resource") ruleResource=unq(v)
      else if (key=="effect") ruleEffect=unq(v)
    }
    skipValue()
    t=adv()
    if (t=="}") return
  }
}
function parseRules(id,   t) {
  adv()
  if (peek()=="]") { adv(); return }
  while (1) {
    if (peek()=="{") { parseRule(); emit(id) }
    else skipValue()
    t=adv()
    if (t=="]") return
  }
}
function parseAgent(id,   t,key) {
  adv()
  if (peek()=="}") { adv(); return }
  while (1) {
    key=unq(adv()); adv()
    if (key=="permissions" && peek()=="[") { kind=1; parseRules(id) }
    else skipValue()
    t=adv()
    if (t=="}") return
  }
}
function parseAgents(   id,t) {
  adv()
  if (peek()=="}") { adv(); return }
  while (1) {
    id=unq(adv()); adv()
    if (peek()=="{") parseAgent(id)
    else skipValue()
    t=adv()
    if (t=="}") return
  }
}
function parseDocument(   t,key) {
  adv()
  if (peek()=="}") { adv(); return }
  while (1) {
    key=unq(adv()); adv()
    if (key=="permissions" && peek()=="[") { kind=0; parseRules("*") }
    else if (key=="agents" && peek()=="{") parseAgents()
    else skipValue()
    t=adv()
    if (t=="}") return
  }
}
function normalize(text,   len,i,c,j,out,instr,len2,res,nc) {
  len=length(text); i=1; out=""; instr=0
  while (i<=len) {
    c=substr(text,i,1)
    if (instr) {
      out=out c
      if (c=="\\") { out=out substr(text,i+1,1); i+=2; continue }
      if (c=="\"") instr=0
      i++; continue
    }
    if (c=="\"") { instr=1; out=out c; i++; continue }
    if (c=="/" && substr(text,i+1,1)=="/") { while (i<=len && substr(text,i,1)!="\n") i++; continue }
    if (c=="/" && substr(text,i+1,1)=="*") {
      i+=2
      while (i<=len && !(substr(text,i,1)=="*" && substr(text,i+1,1)=="/")) i++
      i+=2
      continue
    }
    out=out c; i++
  }
  len2=length(out); i=1; res=""; instr=0
  while (i<=len2) {
    c=substr(out,i,1)
    if (instr) {
      res=res c
      if (c=="\\") { res=res substr(out,i+1,1); i+=2; continue }
      if (c=="\"") instr=0
      i++; continue
    }
    if (c=="\"") { instr=1; res=res c; i++; continue }
    if (c==",") {
      j=i+1
      while (j<=len2 && (substr(out,j,1)==" " || substr(out,j,1)=="\t" || substr(out,j,1)=="\n" || substr(out,j,1)=="\r")) j++
      nc=substr(out,j,1)
      if (nc=="]" || nc=="}") { i++; continue }
    }
    res=res c; i++
  }
  return res
}
{ text = text $0 "\n" }
END {
  norm=normalize(text)
  tokenize(norm)
  pos=0
  if (mode=="doc") {
    if (ntok>0 && tok[1]!="{") die("invalid configuration document")
    if (ntok>0) parseDocument()
  } else {
    k=0
    for (i=1;i<=ntok;i++) { if (tok[i]=="[") { k=i; break } }
    if (k>0) { pos=k-1; parseRules(id) }
  }
}
'

# Convert a YAML block sequence of permission rules to a JSON array.
AWK_YAML='
function esc(s) { gsub(/\\/, "\\\\", s); gsub(/"/, "\\\"", s); return s }
function flush() {
  if (item) {
    printf "%s{\"action\":\"%s\",\"resource\":\"%s\",\"effect\":\"%s\"}", (n++ ? "," : ""), esc(a), esc(r), esc(e)
    item=0
  }
}
function kv(s,   p,key,val) {
  p=index(s, ":"); if (p==0) return
  key=substr(s,1,p-1); val=substr(s,p+1)
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
  gsub(/^"|"$/, "", val)
  if (key=="action") a=val
  else if (key=="resource") r=val
  else if (key=="effect") e=val
}
BEGIN { printf "["; n=0; item=0; a=""; r=""; e="" }
{
  line=$0
  sub(/^[[:space:]]+/, "", line)
  if (line=="") next
  if (line ~ /^-/) {
    flush(); item=1; a=""; r=""; e=""
    sub(/^-+[[:space:]]*/, "", line)
    if (substr(line,1,1)=="{") {
      sub(/^\{/, "", line); sub(/\}[[:space:]]*$/, "", line)
      m=split(line, parts, ",")
      for (i=1;i<=m;i++) kv(parts[i])
    } else if (line!="") kv(line)
  } else {
    kv(line)
  }
}
END { flush(); printf "]\n" }
'

# ---------------------------------------------------------------------------
# The frontmatter `permissions` block of one agent file.
# ---------------------------------------------------------------------------
frontmatter_permissions() {
  awk '
    BEGIN { inf=0; grab=0 }
    $0 == "---" { if (inf==0) { inf=1; next } else { exit } }
    inf==0 { next }
    {
      if (grab==1) {
        if ($0 ~ /^[^[:space:]-]/) { exit }
        print
        next
      }
      if ($0 ~ /^[[:space:]]*permissions[[:space:]]*:/) {
        grab=1
        sub(/^[[:space:]]*permissions[[:space:]]*:[[:space:]]*/, "")
        print
      }
    }
  ' "$1"
}

pick_doc() {
  if [ -f "$1/opencode.jsonc" ]; then
    printf '%s' "$1/opencode.jsonc"
  elif [ -f "$1/opencode.json" ]; then
    printf '%s' "$1/opencode.json"
  else
    :
  fi
}

# The coverage relation (C-CA12, C-FCA-03-02). The resource pattern `$R`
# covers the surface pattern `$S` when the glob `$R` matches the string `$S`.
# The pattern `$R` is unquoted, so its `*` acts as a wildcard.
covers() {
  S=$1
  R=$2
  case "$S" in
    $R) return 0 ;;
    *) return 1 ;;
  esac
}

common_prefix_len() {
  cpa=$1; cpb=$2; cpn=0
  while [ -n "$cpa" ] && [ -n "$cpb" ]; do
    cpa1=${cpa%"${cpa#?}"}
    cpb1=${cpb%"${cpb#?}"}
    if [ "$cpa1" != "$cpb1" ]; then
      break
    fi
    cpn=$((cpn + 1))
    cpa=${cpa#?}
    cpb=${cpb#?}
  done
  printf '%s' "$cpn"
}

# The nearest role of one unowned path (C-CA13, C-FCA-03-06). Ties break by
# the shorter resource pattern, then by the smaller agent name. The agent list
# is sorted, so the first best name wins.
nearest_role() {
  nr_path=$1
  nr_len=-1
  nr_rlen=0
  nr_name=""
  while IFS= read -r nr_id; do
    [ -n "$nr_id" ] || continue
    while IFS="$TAB" read -r nr_rid nr_action nr_resource nr_effect; do
      [ -n "$nr_rid" ] || continue
      if [ "$nr_rid" != "$nr_id" ]; then
        continue
      fi
      if [ "$nr_action" != "edit" ] || [ "$nr_effect" != "allow" ]; then
        continue
      fi
      nr_lit=${nr_resource%%\**}
      nr_l=$(common_prefix_len "$nr_lit" "$nr_path")
      if [ "$nr_l" -gt "$nr_len" ] || { [ "$nr_l" -eq "$nr_len" ] && [ "${#nr_resource}" -lt "$nr_rlen" ]; }; then
        nr_len=$nr_l
        nr_rlen=${#nr_resource}
        nr_name=$nr_id
      fi
    done <<NR_RULES_EOF
$RULES
NR_RULES_EOF
  done <<NR_IDS_EOF
$AGENT_IDS
NR_IDS_EOF
  if [ "$nr_len" -le 0 ]; then
    printf '%s' "-"
  else
    printf '%s' "$nr_name"
  fi
}

# The proposed role name of one unowned path (C-CA16, spec-proposed-role).
propose_name() {
  pn_path=$1
  case "$pn_path" in
    apps/*|services/*|libs/*|deployment/*|e2e/*)
      pn_rest=${pn_path#*/}
      pn_seg=${pn_rest%%/*}
      ;;
    *)
      pn_seg=${pn_path%%/*}
      ;;
  esac
  case "$pn_seg" in
    *\**|'')
      # The segment is a wildcard. Resolve it from the first matching path.
      pn_resolved=""
      while IFS= read -r pn_p; do
        [ -n "$pn_p" ] || continue
        if covers "$pn_p" "$pn_path"; then
          pn_rest=${pn_p#*/}
          pn_resolved=${pn_rest%%/*}
          break
        fi
      done <<PROP_PATHS_EOF
$PROJECT_PATHS
PROP_PATHS_EOF
      if [ -n "$pn_resolved" ]; then
        pn_seg=$pn_resolved
      fi
      ;;
  esac
  pn_name="$pn_seg-expert"
  case " $SHIPPED_ROLES " in
    *" $pn_name "*) pn_name="$pn_name-local" ;;
  esac
  printf '%s' "$pn_name"
}

# ---------------------------------------------------------------------------
# The declaration (spec-coverage-surface interface 3 and 4).
# ---------------------------------------------------------------------------
[ -f "$DECL" ] || err "the declaration $DECL is absent"
[ -r "$DECL" ] || err "the declaration $DECL is not readable"
ENTRIES=$(awk -F"$TAB" '
  /^[[:space:]]*$/ { next }
  /^#/ { next }
  {
    if (NF != 4) { print "coverage: error: declaration line " NR " does not hold four fields" > "/dev/stderr"; bad=1; next }
    if ($2 != "seed" && $2 != "managed" && $2 != "template" && $2 != "none") { print "coverage: error: declaration line " NR " holds an invalid copy mode" > "/dev/stderr"; bad=1 }
    if ($3 != "model" && $3 != "conditional") { print "coverage: error: declaration line " NR " holds an invalid scope" > "/dev/stderr"; bad=1 }
    if (seen[$1]++) { print "coverage: error: declaration class " $1 " appears twice" > "/dev/stderr"; bad=1 }
    print
  }
  END { if (bad) exit 1 }
' "$DECL") || err "the declaration $DECL is invalid"

# The project path list (spec-coverage-scan, the data model).
[ -d "$ROOT" ] || err "the project root $ROOT is not a directory"
PROJECT_PATHS=$(find "$ROOT" -type f 2>/dev/null | sed -e "s|^$ROOT/||" -e 's|^\./||' | sort) || err "the project path list failed"

# The ordered document list (spec-agent-read, the data model).
ABS=$(cd "$ROOT" && pwd) || err "the project root $ROOT is not accessible"
DIRS=""
d=$ABS
while :; do
  DIRS="$d
$DIRS"
  if [ "$d" = "/" ]; then
    break
  fi
  d=${d%/*}
  [ -n "$d" ] || d=/
done

DOCS=""
if [ -n "${HOME:-}" ] && [ -d "$HOME" ]; then
  GLOBAL=$(pick_doc "$HOME/.config/opencode") || err "the global document failed"
  if [ -n "$GLOBAL" ]; then
    DOCS="$GLOBAL"
  fi
fi
while IFS= read -r docdir; do
  [ -n "$docdir" ] || continue
  x=$(pick_doc "$docdir") || err "the direct document failed"
  if [ -n "$x" ]; then
    DOCS="$DOCS
$x"
  fi
done <<DIRS_EOF
$DIRS
DIRS_EOF
while IFS= read -r docdir; do
  [ -n "$docdir" ] || continue
  x=$(pick_doc "$docdir/.opencode") || err "the .opencode document failed"
  if [ -n "$x" ]; then
    DOCS="$DOCS
$x"
  fi
done <<DIRS_EOF2
$DIRS
DIRS_EOF2

# The rule list. kind 0 global, kind 1 configuration agent, kind 2 file form.
ALL=""
di=0
while IFS= read -r doc; do
  [ -n "$doc" ] || continue
  [ -r "$doc" ] || err "the document $doc is not readable"
  di=$((di + 1))
  out=$(awk -v mode=doc -v di="$di" "$AWK_PARSE" "$doc") || err "the document $doc is invalid"
  if [ -n "$out" ]; then
    ALL="$ALL
$out"
  fi
done <<DOCS_EOF
$DOCS
DOCS_EOF

# The file form (spec-agent-read interface 6 and 7). The file form is last.
AGENT_DIR="$ROOT/.opencode/agents"
if [ -d "$AGENT_DIR" ]; then
  AGENT_FILES=$(find "$AGENT_DIR" -type f -name '*.md' | sort) || err "the agent file list failed"
  fi_idx=0
  while IFS= read -r afile; do
    [ -n "$afile" ] || continue
    fi_idx=$((fi_idx + 1))
    arel=${afile#"$AGENT_DIR/"}
    aid=${arel%.md}
    perms_text=$(frontmatter_permissions "$afile") || err "the frontmatter of $afile is invalid"
    first=$(printf '%s\n' "$perms_text" | awk 'match($0, /[^[:space:]]/) { print substr($0, RSTART, 1); exit }') || err "the frontmatter of $afile is invalid"
    if [ "$first" = "[" ]; then
      rules_text=$perms_text
    else
      rules_text=$(printf '%s\n' "$perms_text" | awk "$AWK_YAML") || err "the frontmatter of $afile is invalid"
    fi
    out=$(printf '%s\n' "$rules_text" | awk -v mode=rules -v kind=2 -v di="$fi_idx" -v id="$aid" "$AWK_PARSE") || err "the frontmatter of $afile is invalid"
    if [ -n "$out" ]; then
      ALL="$ALL
$out"
    fi
  done <<AGENT_FILES_EOF
$AGENT_FILES
AGENT_FILES_EOF
fi

SORTED=$(printf '%s\n' "$ALL" | sort -t"$TAB" -k1,1n -k2,2n -k3,3n) || err "the rule sort failed"
RULES=$(printf '%s\n' "$SORTED" | awk -F"$TAB" 'NF>=4 { print $4 "\t" $5 "\t" $6 "\t" $7 }') || err "the rule list failed"
AGENT_IDS=$(printf '%s\n' "$RULES" | awk -F"$TAB" 'NF>=1 && $1!="" && $1!="*" { print $1 }' | sort -u) || err "the agent list failed"

# ---------------------------------------------------------------------------
# The classification, the coverage, and the report.
# ---------------------------------------------------------------------------
entries_total=0
unowned_total=0
row_lines=""

while IFS="$TAB" read -r class cm scope pattern; do
  [ -n "$class" ] || continue
  if [ "$cm" = "managed" ]; then
    continue
  fi
  if [ "$scope" = "conditional" ]; then
    amatch=0
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      if covers "$p" "$pattern"; then
        amatch=1
        break
      fi
    done <<PROJECT_PATHS_EOF
$PROJECT_PATHS
PROJECT_PATHS_EOF
    if [ "$amatch" -eq 0 ]; then
      continue
    fi
  fi
  entries_total=$((entries_total + 1))
  is_covered=0
  while IFS= read -r aid; do
    [ -n "$aid" ] || continue
    last_effect=""
    while IFS="$TAB" read -r rid raction rresource reffect; do
      [ -n "$rid" ] || continue
      if [ "$rid" = "$aid" ] || [ "$rid" = "*" ]; then
        if [ "$raction" = "edit" ]; then
          if covers "$pattern" "$rresource"; then
            last_effect="$reffect"
          fi
        fi
      fi
    done <<RULES_EOF
$RULES
RULES_EOF
    if [ "$last_effect" = "allow" ]; then
      is_covered=1
      break
    fi
  done <<AGENT_IDS_EOF
$AGENT_IDS
AGENT_IDS_EOF
  if [ "$is_covered" -eq 0 ]; then
    unowned_total=$((unowned_total + 1))
    nearest=$(nearest_role "$pattern") || err "the nearest role failed"
    proposed=$(propose_name "$pattern") || err "the proposed role failed"
    row_lines="$row_lines
$pattern$TAB$cm$TAB$nearest$TAB$proposed$TAB$pattern"
  fi
done <<ENTRIES_EOF
$ENTRIES
ENTRIES_EOF

printf 'coverage: %s entries, %s unowned author paths\n' "$entries_total" "$unowned_total"
if [ "$unowned_total" -gt 0 ]; then
  ROWS=$(printf '%s\n' "$row_lines" | awk 'NF>0' | sort -t"$TAB" -k1,1) || err "the report sort failed"
  printf '%s\n' "$ROWS" | awk -F"$TAB" 'NF>=4 { print $1 "\t" $2 "\t" $3 "\t" $4 }' || err "the report rows failed"
  PROP_PAIRS=$(printf '%s\n' "$ROWS" | awk -F"$TAB" 'NF>=5 { print $4 "\t" $5 }' | sort -u) || err "the proposal sort failed"
  PROP_ROLES=$(printf '%s\n' "$PROP_PAIRS" | awk -F"$TAB" 'NF>=1 { print $1 }' | sort -u) || err "the proposal role list failed"
  while IFS= read -r role; do
    [ -n "$role" ] || continue
    printf 'proposal: %s\n' "$role"
    printf '%s\n' "$PROP_PAIRS" | awk -F"$TAB" -v r="$role" 'NF>=2 && $1==r { print $2 }' | sort -u | sed 's/^/- /' || err "the proposal patterns failed"
  done <<PROP_ROLES_EOF
$PROP_ROLES
PROP_ROLES_EOF
fi

if [ "$unowned_total" -eq 0 ]; then
  exit 0
fi
exit 1
