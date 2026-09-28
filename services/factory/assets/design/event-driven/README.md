# Event-Driven Delivery

Event-driven design is the delivery facet of domain-driven design (DDD). It describes how a system
moves events between its parts. The [Domain-Driven Design](../ddd/README.md) guide gives the design
method and the domain model. This page gives the delivery of the events.

## What a domain event is

A domain event is a fact that happened in the business. Write the event in the past tense. Example:
"Delivery cancelled". An aggregate emits the event after a change of state. The event is immutable.
The event holds the name, the time, and the data of the change.

The domain event is a model element. The bounded context canvas and the aggregate canvas name the
events. The aggregate canvas gives the created events of one aggregate. The context canvas gives the
inbound messages and the outbound messages of one context.

## How events move between the parts

A command is a request to change the state. One aggregate or one domain service handles one command.
A command can fail. A domain event cannot fail.

A policy is a rule of the form "when this event, then this command". A policy connects two
aggregates or two contexts. The policy reads one domain event and sends one command to the next
aggregate. The next aggregate emits the events of its own change.

Inside one context, a policy moves the event between two aggregates. Between two contexts, the
context map gives the relationship. An upstream context sends the event to a downstream context. A
published language is the documented, shared format of the messages across the boundary. An
anticorruption layer translates the upstream model into the downstream model.

This table gives the movement of one event through the parts of a system:

| Step | Part | Action |
| --- | --- | --- |
| 1 | Command handler | Handle one command and change one aggregate. |
| 2 | Aggregate | Emit one domain event after the change of state. |
| 3 | Policy | Read the event and send one command to the next aggregate or context. |
| 4 | Context boundary | Carry the event to the downstream context in the published language. |
| 5 | Anticorruption layer | Translate the upstream model into the downstream model. |

## The model and the delivery

Event-driven design has two parts. The design part models the events. The delivery part moves the
events.

Inside DDD, the designer models the event. The domain event, the command, and the policy are model
elements of one bounded context. The effort goes to the meaning: the name, the data, the invariant,
and the reaction. The domain model lives in `docs/domain/`.

Outside DDD, the delivery moves the event. The delivery holds the transport, the broker, the queue,
the topic, the order, the retry, and the dead-letter queue. The delivery concern is infrastructure.
It holds no business rule. A change to the transport does not change the domain model.

Keep the two parts apart. The domain model names the event and gives its meaning. The delivery moves
the event and keeps its order. Do not put a delivery detail in the domain model. Do not put a
business rule in the delivery.

## Relationship to the DDD guide

Read the [Domain-Driven Design](../ddd/README.md) guide first. The guide gives the strategic design,
the tactical design, the aggregate, the domain event, the command, and the policy. This page
continues the domain event into the delivery.

The guide [maps each design step to one of the five phases](../ddd/artifact-driven.md). The delivery
of the events belongs to phase 4, the implementation. The code of a context lives in
`services/<name>/`.
