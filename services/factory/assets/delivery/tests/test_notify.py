"""Stub test of the notifier (spec-notify-fanout).

Usage: python3 test_notify.py <path to notify.py>. The test injects a stub
transport and a stub sleep and imports the script. Each failed item exits
with a non-zero code and names the item.
"""

import importlib.util
import io
import json
import os
import sys
from contextlib import redirect_stderr, redirect_stdout


def load_notify(path):
    spec = importlib.util.spec_from_file_location("notify_under_test", path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


BASE_ENV = {
    "NOTIFY_USES": '["google-chat", "slack", "telegram"]',
    "NOTIFY_GOOGLE_CHAT_WEBHOOK": "https://chat.example/hook",
    "NOTIFY_SLACK_WEBHOOK": "https://slack.example/hook",
    "NOTIFY_TELEGRAM_TOKEN": "token-value",
    "NOTIFY_TELEGRAM_CHAT_ID": "123456789",
    "NOTIFY_DEPLOYMENT_URL": "https://owner.github.io/repository/",
    "NOTIFY_REPOSITORY": "owner/repository",
    "NOTIFY_REF_NAME": "main",
    "NOTIFY_COMMIT_SHA": "0123456789abcdef",
    "NOTIFY_RUN_URL": "https://example/runs/1",
}

EXPECTED_TEXT = (
    "Documentation site deployed: owner/repository\n"
    + "URL: https://owner.github.io/repository/\n"
    + "Source: main @ 0123456\n"
    + "Run: https://example/runs/1"
)


class StubTransport:
    def __init__(self, script):
        self.calls = []
        self.script = list(script)

    def __call__(self, url, data, headers):
        self.calls.append((url, data, headers))
        return self.script.pop(0) if self.script else 200


class StubSleep:
    def __init__(self):
        self.calls = []

    def __call__(self, seconds):
        self.calls.append(seconds)


def set_env(extra):
    for key in list(BASE_ENV.keys()) + ["NOTIFY_USES"]:
        os.environ.pop(key, None)
    os.environ.update(BASE_ENV)
    os.environ.update(extra)


def check(name, condition):
    if not condition:
        print("FAIL " + name)
        sys.exit(1)
    print("PASS " + name)


def main():
    notify = load_notify(sys.argv[1])

    set_env({})
    transport = StubTransport([200, 200, 200])
    sleep = StubSleep()
    out = io.StringIO()
    err = io.StringIO()
    with redirect_stdout(out), redirect_stderr(err):
        code = notify.run(transport=transport, sleep=sleep)
    check("payload-channels", code == 0)
    check("payload-count", len(transport.calls) == 3)
    bodies = [json.loads(call[1].decode("utf-8")) for call in transport.calls]
    check("payload-same-text", all(b.get("text") == EXPECTED_TEXT for b in bodies))
    check("payload-webhook-shape", bodies[0] == {"text": EXPECTED_TEXT})
    check("payload-slack-shape", bodies[1] == {"text": EXPECTED_TEXT})
    check(
        "payload-telegram-shape",
        bodies[2] == {"chat_id": "123456789", "text": EXPECTED_TEXT},
    )
    telegram_url = transport.calls[2][0]
    check(
        "payload-telegram-target",
        telegram_url == "https://api.telegram.org/bottoken-value/sendMessage",
    )
    check(
        "payload-order",
        [call[0] for call in transport.calls]
        == [
            "https://chat.example/hook",
            "https://slack.example/hook",
            "https://api.telegram.org/bottoken-value/sendMessage",
        ],
    )

    set_env({})
    transport = StubTransport([200, 500, 500, 500, 200])
    sleep = StubSleep()
    with redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
        code = notify.run(transport=transport, sleep=sleep)
    check("fanout-failure-code", code != 0)
    check("fanout-continues", len(transport.calls) == 5)

    set_env({"NOTIFY_USES": '["slack"]'})
    transport = StubTransport([500, 500, 500])
    sleep = StubSleep()
    with redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
        code = notify.run(transport=transport, sleep=sleep)
    check("retry-code", code != 0)
    check("retry-attempts", len(transport.calls) == 3)
    check("retry-delays", sleep.calls == [1, 2])

    def failing(url, data, headers):
        raise ConnectionError("down")

    set_env({"NOTIFY_USES": '["slack"]'})
    sleep = StubSleep()
    attempts = {"count": 0}

    def counting(url, data, headers):
        attempts["count"] += 1
        return failing(url, data, headers)

    with redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
        code = notify.run(transport=counting, sleep=sleep)
    check("retry-network", code != 0 and attempts["count"] == 3)

    set_env({"NOTIFY_USES": '["slack"]'})
    transport = StubTransport([403])
    sleep = StubSleep()
    with redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
        code = notify.run(transport=transport, sleep=sleep)
    check("no-retry-4xx", code != 0 and len(transport.calls) == 1)
    check("no-retry-4xx-sleep", sleep.calls == [])

    set_env({})
    os.environ["NOTIFY_SLACK_WEBHOOK"] = "https://hooks.example/secret-abc-123"
    transport = StubTransport([200, 200, 200])
    sleep = StubSleep()
    out = io.StringIO()
    err = io.StringIO()
    with redirect_stdout(out), redirect_stderr(err):
        notify.run(transport=transport, sleep=sleep)
    check("no-secret-stdout", "secret-abc-123" not in out.getvalue())
    check("no-secret-stderr", "secret-abc-123" not in err.getvalue())

    set_env({"NOTIFY_USES": "[]"})
    transport = StubTransport([])
    sleep = StubSleep()
    out = io.StringIO()
    with redirect_stdout(out), redirect_stderr(io.StringIO()):
        code = notify.run(transport=transport, sleep=sleep)
    check("empty-uses-quiet", code == 0 and transport.calls == [])

    print("ALL GREEN")


if __name__ == "__main__":
    main()
