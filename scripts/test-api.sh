#!/usr/bin/env bash
set -e

DEMO_TOKEN="week12-demo-secret-token-2026"
ADMIN_TOKEN="week12-admin-secret-token-2026"
BASE_URL="http://127.0.0.1:8787"

echo "=========================================="
echo "1. Health Check"
echo "=========================================="
curl -s "$BASE_URL/api/health" | jq .
echo ""

echo "=========================================="
echo "2. Re-indexing Admin API"
echo "=========================================="
curl -s -X POST "$BASE_URL/api/admin/index" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq .
echo ""

echo "=========================================="
echo "3. RAG Grounded Recommendation"
echo "=========================================="
curl -s -G "$BASE_URL/api/recommend" \
  -H "Authorization: Bearer $DEMO_TOKEN" \
  --data-urlencode "q=I want a beginner-friendly book about relational databases." | jq .
echo ""

echo "=========================================="
echo "4. Hallucination Risk Test"
echo "=========================================="
curl -s -G "$BASE_URL/api/recommend" \
  -H "Authorization: Bearer $DEMO_TOKEN" \
  --data-urlencode "q=Do you sell Advanced Quantum Computing?" | jq .
echo ""

