# or-model-rotate

Round-robin selection of free OpenRouter models for LLM subagent spawns.

Free OpenRouter models each have their own rate-limit bucket
(20 req/min, 1000 req/day per model), so rotating across models spreads
throughput instead of sharing one model's quota.

```
./or-model-rotate.sh            # print next model (and advance state)
./or-model-rotate.sh --peek     # print next model without advancing
./or-model-rotate.sh --list     # list all models in rotation
./or-model-rotate.sh --batch 7  # print N distinct models, one per line
```

## Why

If you run parallel LLM subagents on OpenRouter free tier, one model's
1000 req/day cap becomes the bottleneck. Rotation keeps N models in the
pool so your aggregate throughput is N× the single-model limit.

## Config

- Models are defined in the `MODELS` array at the top of the script.
- State file defaults to `.or-model-state` next to the script
  (override with `OR_ROTATE_STATE`).

No API key needed — this only selects model IDs.
