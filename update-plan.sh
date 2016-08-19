#!/bin/bash

PLAN_DIR="${HOME}/dot-plan"
TEMPLATE="${PLAN_DIR}/plan-template"

create_plan() {
    cp "$TEMPLATE" "$1"
    plan_number=${1#${PLAN_DIR}/plan-}
    previous_plan="${PLAN_DIR}/plan-$(($plan_number - 1))"
    if [ -e "$previous_plan" ]; then
        <"$previous_plan" sed -rne '/^[.]/ s/^/; /p' >> $1
        echo >> $1
        <"$previous_plan" sed -rne '/^[>^]/ {s/^>/./; p;}' >> $1
    fi
}

usage() {
    cat <<EOF >&2
$0      -- edit plan for this week
$0 next -- edit plan for next week
$0 last -- edit plan for last week
$0 help -- show this usage message
EOF
    exit 0
}

edit_plan_for() {
    week_num=$1
    plan_path="${PLAN_DIR}/plan-${1}"
    [ -e "${plan_path}" ] || create_plan "${plan_path}"

    $EDITOR "${plan_path}"
}

ensure_current_link() {
    rm "${PLAN_DIR}/current" && ln -s "plan-$(date +%U)" "${PLAN_DIR}/current"
}

case $1 in
    next) edit_plan_for "$(date --date 'next week' +%U)";;
    last) edit_plan_for "$(date --date 'last week' +%U)";;
    help) usage;;
    *) edit_plan_for "$(date +%U)"; ensure_current_link;;
esac
