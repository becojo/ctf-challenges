# ParrotLM 🦜

**Categories**: `web` `ai` `appsec`

> ParrotLM is a state of the art, secure, stateless, deterministic AI assistant. In the past few weeks, it was noticed that illegitimate users were abusing the API quota of other ParrotLM users. We suspect a vulnerability exists that allows an attacker to steal other users' API keys.
>
> Can you help us investigate the root cause of this issue and fix it?

## Setup

In the [`src`](src) folder, setup the Python environment and install dependencies using the following command:
```bash
uv sync
```

## Exploitation Instructions

To start the server and attempt to reproduce the vulnerability, run the following command:

```bash
uv run main.py
```

The server will be available on http://0.0.0.0:8080.

## Patching Instructions

To fix the vulnerability, make changes in the code in the [`src`](src) folder.

To validate the service is working correctly, run the following command:
```python
uv run -m unittest discover -s tests -p test_usability.py
```

To validate that your changes addresses the vulnerability, run the following command:
```python
uv run -m unittest discover -s tests -p test_security.py
```
