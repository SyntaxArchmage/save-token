#!/usr/bin/env bash
# LLMLingua-2 engine: perplexity-based prompt pruning for natural language.
# Requires: pip install llmlingua

if ! python3 -c "import llmlingua" 2>/dev/null; then
  echo "[compress] llmlingua not installed. Run: compress.sh --install=llmlingua" >&2
  cat
  exit 0
fi

python3 -c "
import sys
from llmlingua import PromptCompressor

text = sys.stdin.read()
compressor = PromptCompressor(model_name='microsoft/llmlingua-2-bert-base-multilingual-cased-meetingbank')
result = compressor.compress_prompt(text, rate=0.5)
print(result['compressed_prompt'])
"
