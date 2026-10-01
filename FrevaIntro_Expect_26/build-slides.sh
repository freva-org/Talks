#!/usr/bin/env bash

# Build FrevaIntro.ipynb as the Reveal.js deck index.slides.html.
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_notebook="${script_dir}/FrevaIntro.ipynb"
style_notebook="${script_dir}/style.ipynb"
output_name="index"
output_file="${script_dir}/${output_name}.slides.html"
merged_notebook="$(mktemp "${script_dir}/.merged-slides.XXXXXX.ipynb")"

cleanup() {
    rm -f -- "${merged_notebook}"
}
trap cleanup EXIT

for required_file in "${source_notebook}" "${style_notebook}"; do
    if [[ ! -f "${required_file}" ]]; then
        echo "Missing required file: ${required_file}" >&2
        exit 1
    fi
done

if ! command -v nbmerge >/dev/null 2>&1; then
    echo "nbmerge is required. Install it once with: python -m pip install nbmerge" >&2
    exit 1
fi

# Merge styling notebook + presentation notebook.
nbmerge "${style_notebook}" "${source_notebook}" > "${merged_notebook}"

# Convert merged notebook to Reveal.js slides.
jupyter nbconvert "${merged_notebook}" \
    --to slides \
    --output "${output_name}" \
    --output-dir "${script_dir}" \
    --TagRemovePreprocessor.enabled=True \
    --TagRemovePreprocessor.remove_input_tags='{"hide_input"}' \
    --TagRemovePreprocessor.remove_cell_tags='{"remove_cell"}' \
    --SlidesExporter.reveal_transition=fade \
    --SlidesExporter.reveal_theme=simple \
    --SlidesExporter.reveal_scroll=True

# Set browser tab title.
sed -i 's|<title>[^<]*</title>|<title>Freva Intro Expect26</title>|' "${output_file}"

echo "Slides generated: ${output_file}"