#!/bin/bash
# run_all_tests.sh — Run all Scilab function tests
# Usage:
#   bash tests/run_all_tests.sh          # run all 3 functions
#   bash tests/run_all_tests.sh immse    # run only immse

PASS=0
FAIL=0
ERRORS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCILAB_CMD="scilab-cli"

# Check Scilab is installed
if ! command -v $SCILAB_CMD &> /dev/null; then
    echo -e "${RED}ERROR: scilab-cli not found.${NC}"
    echo "Install with:  sudo apt-get install -y scilab scilab-cli"
    exit 1
fi

SCILAB_VERSION=$($SCILAB_CMD -version 2>&1 | head -1)
echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  $SCILAB_VERSION${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

run_test() {
    local name=$1
    local script=$2
    echo -e "${YELLOW}▶ Running: $name${NC}"
    $SCILAB_CMD -nb -f "$script" > /tmp/test_output.txt 2>&1
    local exit_code=$?
    cat /tmp/test_output.txt
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}   $name — PASSED${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}   $name — FAILED (exit code: $exit_code)${NC}"
        FAIL=$((FAIL + 1))
        ERRORS+=("$name")
    fi
    echo ""
}

FILTER=${1:-"all"}

if [[ "$FILTER" == "all" || "$FILTER" == "immse" ]]; then
    run_test "immse"        "tests/test_immse.sci"
fi

if [[ "$FILTER" == "all" || "$FILTER" == "otsuthresh" ]]; then
    run_test "otsuthresh"   "tests/test_otsuthresh.sci"
fi

if [[ "$FILTER" == "all" || "$FILTER" == "imgradientxy" ]]; then
    run_test "imgradientxy" "tests/test_imgradientxy.sci"
fi

echo -e "${CYAN}============================================${NC}"
echo -e "  Total Passed : ${GREEN}$PASS${NC}"
echo -e "  Total Failed : ${RED}$FAIL${NC}"

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "  Failed tests : ${RED}${ERRORS[*]}${NC}"
fi
echo -e "${CYAN}============================================${NC}"
echo ""

if [ $FAIL -gt 0 ]; then
    exit 1
fi
