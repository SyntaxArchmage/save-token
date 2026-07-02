#!/usr/bin/env bash
# LLMLingua-2 engine: perplexity-based prompt pruning for natural language.
# Requires: pip install llmlingua
# NOTE: First run downloads a model from HuggingFace (BERT-base, ~500MB).
# Requires internet access. Uses llmlingua-2 (BERT-based, faster than original Llama-2).

if ! python3 -c "import llmlingua" 2>/dev/null; then
  echo "[compress] llmlingua not installed. Run: compress.sh --install=llmlingua" >&2
  cat
  exit 0
fi

python3 -c "
import sys, os
os.environ.setdefault('TOKENIZERS_PARALLELISM', 'false')

text = sys.stdin.read()
if not text.strip():
    sys.exit(0)

try:
    from llmlingua import PromptCompressor
    compressor = PromptCompressor(
        model_name='microsoft/llmlingua-2-bert-base-multilingual-cased-meetingbank',
        use_llmlingua2=True,
    )
    result = compressor.compress_prompt(text, rate=0.5)
    print(result['compressed_prompt'])
except Exception as e:
    print(f'[compress] llmlingua error: {e}', file=sys.stderr)
    print(text)
"
