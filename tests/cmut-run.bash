#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 AlgorIT Software Consultancy <https://github.com/algoritnl>
# SPDX-License-Identifier: CC0-1.0

cmut_run() {
    local script_dir
    script_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

    source "${script_dir}/cmut-lib.bash"

    local cmake_module_path
    cmake_module_path="$(realpath "${script_dir}/../cmake")"

    local _total_count=0
    local _failed_count=0

    local _cmake_version
    _cmake_version="$(cmake --version 2>/dev/null | head -n 1)"

    printf -- "===================================================================\n"
    printf -- " Starting Global MultipleChoice CMake Test Suite\n"
    printf -- " Running with:   %s\n" "${_cmake_version:-Unknown CMake version}"
    printf -- "===================================================================\n"

    local test_cases=("$@")
    if [[ ${#test_cases[@]} -eq 0 ]]; then
        test_cases=("${script_dir}"/test-*.tc)
    fi

    local test_case
    for test_case in "${test_cases[@]}"; do
        [[ -f ${test_case} ]] || continue

        local test_name
        test_name="$(basename "${test_case}" .tc)"

        _total_count=$((_total_count + 1))

        unset -f cmut_generate_cb cmut_assert_cb
        # shellcheck disable=SC1090 # non-constant source
        source "${test_case}"

        if ! declare -F cmut_generate_cb >/dev/null || ! declare -F cmut_assert_cb >/dev/null; then
            local dots
            printf -v dots "%.s." {1..50}
            printf "Running: %.50s ❌ INVALID\n" "${test_name:0:46} ${dots}"
            _failed_count=$((_failed_count + 1))
            unset -f cmut_generate_cb cmut_assert_cb
            continue
        fi

        # shellcheck disable=SC2310 # set -e will be disabled
        if ! cmut_run_test_case "${test_name}" "${cmake_module_path}" cmut_generate_cb cmut_assert_cb; then
            _failed_count=$((_failed_count + 1))
        fi

        unset -f cmut_generate_cb cmut_assert_cb
    done

    printf -- "===================================================================\n"
    printf -- " Test Execution Summary\n"
    printf -- "-------------------------------------------------------------------\n"
    printf -- " Total tests run: %2d\n" "${_total_count}"
    printf -- " Passed:          %2d\n" "$((_total_count - _failed_count))"
    printf -- " Failed:          %2d\n" "${_failed_count}"
    printf -- "===================================================================\n"

    if [[ ${_failed_count} -gt 0 ]]; then
        printf "❌ Suite FAILED with %d error(s).\n" "${_failed_count}" >&2
        return 1
    fi

    printf "✅ All tests PASSED successfully.\n"
    return 0
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    set -euo pipefail
    cmut_run "$@"
fi
