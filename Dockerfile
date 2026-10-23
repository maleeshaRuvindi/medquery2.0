FROM public.ecr.aws/lambda/python:3.12

# uv binary
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Dependencies first (cached layer unless pyproject/uv.lock change)
COPY pyproject.toml uv.lock ./
RUN uv export --frozen --no-dev --no-hashes --no-emit-project -o requirements.txt \
    && uv pip install --compile-bytecode --no-cache -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# App code
COPY lambda_handler.py ${LAMBDA_TASK_ROOT}/
COPY agent/ ${LAMBDA_TASK_ROOT}/agent/
COPY guardrails/ ${LAMBDA_TASK_ROOT}/guardrails/
COPY data/mimic_hosp.db ${LAMBDA_TASK_ROOT}/data/mimic_hosp.db

CMD ["lambda_handler.handler"]