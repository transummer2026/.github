#!/usr/bin/env bash
set -euo pipefail

: "${OTEL_ENDPOINT:?OTEL_ENDPOINT manquant}"
SERVICE="${SERVICE:-unknown}"
REPO="${REPO:-unknown}"
BRANCH="${BRANCH:-unknown}"
DURATION_MS="${DURATION_MS:-0}"
STATUS_CODE="${STATUS_CODE:-2}"
STATUS_RESULT="${STATUS_RESULT:-failure}"
RUN_ID="${RUN_ID:-0}"
RUN_NUMBER="${RUN_NUMBER:-0}"
ACTOR="${ACTOR:-unknown}"
TEST_COUNT="${TEST_COUNT:-0}"
COVERAGE="${COVERAGE:-0}"

TRACE_ID=$(cat /proc/sys/kernel/random/uuid | tr -d '-' | head -c 32)
SPAN_ID=$(cat /proc/sys/kernel/random/uuid | tr -d '-' | head -c 16)
END_NS=$(date +%s%N)
START_NS=$(( END_NS - DURATION_MS * 1000000 ))

curl -sf --max-time 30 -X POST "${OTEL_ENDPOINT}/v1/traces" \
  -H "Content-Type: application/json" \
  -d "{
    \"resourceSpans\": [{
      \"resource\": {
        \"attributes\": [
          {\"key\": \"service.name\", \"value\": {\"stringValue\": \"${SERVICE}\"}},
          {\"key\": \"deployment.environment\", \"value\": {\"stringValue\": \"ci\"}},
          {\"key\": \"ci.provider\", \"value\": {\"stringValue\": \"github-actions\"}},
          {\"key\": \"ci.repo\", \"value\": {\"stringValue\": \"${REPO}\"}},
          {\"key\": \"ci.branch\", \"value\": {\"stringValue\": \"${BRANCH}\"}}
        ]
      },
      \"scopeSpans\": [{
        \"spans\": [{
          \"traceId\": \"${TRACE_ID}\",
          \"spanId\": \"${SPAN_ID}\",
          \"name\": \"ci/${SERVICE}\",
          \"startTimeUnixNano\": \"${START_NS}\",
          \"endTimeUnixNano\": \"${END_NS}\",
          \"status\": {\"code\": ${STATUS_CODE}},
          \"attributes\": [
            {\"key\": \"ci.run_id\", \"value\": {\"stringValue\": \"${RUN_ID}\"}},
            {\"key\": \"ci.run_number\", \"value\": {\"stringValue\": \"${RUN_NUMBER}\"}},
            {\"key\": \"ci.actor\", \"value\": {\"stringValue\": \"${ACTOR}\"}},
            {\"key\": \"ci.status\", \"value\": {\"stringValue\": \"${STATUS_RESULT}\"}},
            {\"key\": \"ci.duration_ms\", \"value\": {\"intValue\": ${DURATION_MS}}},
            {\"key\": \"ci.test_count\", \"value\": {\"intValue\": ${TEST_COUNT}}},
            {\"key\": \"ci.coverage\", \"value\": {\"intValue\": ${COVERAGE}}}
          ]
        }]
      }]
    }]
  }"
