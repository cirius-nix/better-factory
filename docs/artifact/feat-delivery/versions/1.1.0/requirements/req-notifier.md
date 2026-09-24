# req-notifier: One notifier for deploy messages

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must send deploy messages through one notifier fan-out with the
channels google-chat, slack, and telegram. The notifier serves deploy messages
only, and it holds secret names only with values in `.env` or CI secrets.

## Acceptance criteria

- Given a deploy event, when the notifier sends the message, then each
  selected channel receives the same deploy message.
- Given any other event type, when the factory runs, then the notifier sends
  no message for it.
- Given a notifier with secrets, when the author reads the declaration, then
  it holds secret names only and no secret values.

## Notes

- Decision: the notifier serves deploy messages only; no other message uses it.
- This requirement replaces the duplicated notifier options with one path.
