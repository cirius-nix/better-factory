"""One deploy notifier (spec-notify-fanout).

Sends one plain-text deploy message to each selected channel in the list
order of NOTIFY_USES. The channels are google-chat, slack, and telegram.
The HTTP transport and the sleep function are function parameters so the
check injects a stub transport and a stub sleep. The defaults are the real
transport and the real sleep. This file holds one transport call and one
sleep call only.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request

MAX_MESSAGE = 3500
RETRY_DELAYS = [1, 2]

CHANNELS = ("google-chat", "slack", "telegram")


def _real_transport(url, data, headers):
    """Post the payload and return the HTTP status code."""
    request = urllib.request.Request(url, data=data, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            response.read()
            return response.status
    except urllib.error.HTTPError as error:
        return error.code


def _real_sleep(seconds):
    time.sleep(seconds)


def _read_env(name):
    return os.environ.get(name, "")


def build_message():
    """Build the one message of the contract."""
    repository = _read_env("NOTIFY_REPOSITORY")
    url = _read_env("NOTIFY_DEPLOYMENT_URL")
    ref = _read_env("NOTIFY_REF_NAME")
    sha = _read_env("NOTIFY_COMMIT_SHA")[:7]
    run_url = _read_env("NOTIFY_RUN_URL")
    return (
        "Documentation site deployed: " + repository + "\n"
        + "URL: " + url + "\n"
        + "Source: " + ref + " @ " + sha + "\n"
        + "Run: " + run_url
    )


def channel_target(channel):
    """Return the post target and payload of one channel."""
    message = build_message()
    if channel == "google-chat":
        return (_read_env("NOTIFY_GOOGLE_CHAT_WEBHOOK"), {"text": message})
    if channel == "slack":
        return (_read_env("NOTIFY_SLACK_WEBHOOK"), {"text": message})
    if channel == "telegram":
        token = _read_env("NOTIFY_TELEGRAM_TOKEN")
        target = "https://api.telegram.org/bot" + token + "/sendMessage"
        payload = {"chat_id": _read_env("NOTIFY_TELEGRAM_CHAT_ID"), "text": message}
        return (target, payload)
    return (None, None)


def _retryable(status):
    return status == 429 or (status is not None and 500 <= status <= 599)


def send_channel(channel, transport, sleep):
    """Send the message to one channel. Return True on success."""
    target, payload = channel_target(channel)
    if not target or not payload:
        print(channel + ": failed: missing input", file=sys.stderr)
        return False
    data = json.dumps(payload).encode("utf-8")
    headers = {"Content-Type": "application/json"}
    status = None
    for attempt in range(3):
        try:
            status = transport(target, data, headers)
        except Exception:
            status = None
        if status is not None and 200 <= status <= 299:
            print(channel + ": " + str(status))
            return True
        if status is not None and not _retryable(status):
            print(channel + ": " + str(status), file=sys.stderr)
            return False
        if attempt < 2:
            sleep(RETRY_DELAYS[attempt])
    print(channel + ": " + str(status), file=sys.stderr)
    return False


def run(transport=_real_transport, sleep=_real_sleep):
    """Send the message to each selected channel. Return the exit code."""
    try:
        uses = json.loads(_read_env("NOTIFY_USES") or "[]")
    except json.JSONDecodeError:
        print("notify: failed: NOTIFY_USES is not a JSON list", file=sys.stderr)
        return 1
    if not isinstance(uses, list):
        print("notify: failed: NOTIFY_USES is not a JSON list", file=sys.stderr)
        return 1
    unknown = [c for c in uses if c not in CHANNELS]
    if unknown:
        print("notify: failed: unknown channel " + str(unknown[0]), file=sys.stderr)
        return 1
    if uses == []:
        print("notify: no channel selected")
        return 0
    message = build_message()
    if len(message) > MAX_MESSAGE:
        print("notify: failed: message above 3500 characters", file=sys.stderr)
        return 1
    failed = False
    for channel in uses:
        if not send_channel(channel, transport, sleep):
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(run())
