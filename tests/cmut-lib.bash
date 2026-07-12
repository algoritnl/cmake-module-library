#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 AlgorIT Software Consultancy <https://github.com/algoritnl>
# SPDX-License-Identifier: CC0-1.0

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    printf "This script is intended to be sourced, not executed directly.\n" >&2
    exit 1
fi

cmut_setup() {
    CMUT_TMPDIR="$(mktemp -d /tmp/cmut_XXXXXX)"
    export CMUT_TMPDIR
}

cmut_teardown() {
    if [[ -d ${CMUT_TMPDIR:-} ]]; then
        rm -rf "${CMUT_TMPDIR}"
    fi

    unset -v CMUT_TMPDIR
}

cmut_cmake_configure() {
    if [[ ! -d ${CMUT_TMPDIR:-} ]]; then
        printf "[Error] Call cmut_setup to create a temporary directory.\n" >&2
        return 1
    fi

    local build_dir
    build_dir="${CMUT_TMPDIR}/build"

    CMUT_STDOUT_LOG="${CMUT_TMPDIR}/stdout.log"
    CMUT_STDERR_LOG="${CMUT_TMPDIR}/stderr.log"

    local cmake_rc
    cmake --log-level=TRACE -S "${CMUT_TMPDIR}" -B "${build_dir}" >"${CMUT_STDOUT_LOG}" 2>"${CMUT_STDERR_LOG}" || cmake_rc=$?

    CMUT_RC="${cmake_rc:-0}"

    export CMUT_STDOUT_LOG
    export CMUT_STDERR_LOG
    export CMUT_RC
}

cmut_assert_run_success() {
    [[ ${CMUT_RC:-1} -eq 0 ]]
}

cmut_assert_run_failed() {
    [[ ${CMUT_RC:-0} -ne 0 ]]
}

cmut_assert_stderr_contains() {
    if [[ $# -ne 1 ]]; then
        printf "[Error] Usage: cmut_assert_stderr_contains <substring>\n" >&2
        return 1
    fi

    local -r substring="$1"

    _cmut_assert_logfile_contains "${CMUT_STDERR_LOG}" "${substring}"
}

cmut_assert_stdout_contains() {
    if [[ $# -ne 1 ]]; then
        printf "[Error] Usage: cmut_assert_stdout_contains <substring>\n" >&2
        return 1
    fi

    local -r substring="$1"

    _cmut_assert_logfile_contains "${CMUT_STDOUT_LOG}" "${substring}"
}

_cmut_assert_logfile_contains() {
    local -r log_file="$1"
    local -r substring="$2"

    if [[ ! -f ${log_file} ]]; then
        printf "[Fail] Expected logfile missing at: %s\n" "${log_file}" >&2
        return 1
    fi

    local grep_rc
    grep -qF -- "${substring}" "${log_file}" || grep_rc=$?

    [[ ${grep_rc:-0} -eq 0 ]]
}

cmut_run_test_case() {
    if [[ $# -ne 4 ]]; then
        printf "[Error] Usage: cmut_run_test_case <test_name> <cmake_module_path> <generate_cb_name> <assert_cb_name>\n" >&2
        return 1
    fi

    local -r test_name="$1"
    local -r cmake_module_path="$2"
    local -r generate_cb="$3"
    local -r assert_cb="$4"

    local dots
    printf -v dots "%.s." {1..50}
    printf "Running: %.50s " "${test_name:0:46} ${dots}"

    cmut_setup
    "${generate_cb}" "${test_name}" "${cmake_module_path}" >"${CMUT_TMPDIR}/CMakeLists.txt"
    cmut_cmake_configure

    if ! "${assert_cb}"; then
        printf "❌ FAIL\n"
        printf -- "-------------------------------------------------------------------\n"
        printf -- "Test failed! Artifacts available at: %s\n" "${CMUT_TMPDIR}"
        printf -- "-------------------------------------------------------------------\n"

        if [[ -s ${CMUT_STDERR_LOG:-} ]]; then
            cat "${CMUT_STDERR_LOG}"
            printf -- "-------------------------------------------------------------------\n"
        fi
        return 1
    fi

    printf "✅ PASS\n"
    cmut_teardown

    return 0
}
