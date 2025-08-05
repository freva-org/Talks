#!/usr/bin/env bash

set -e

usage() {
  echo "Usage: $0 -i notebook.ipynb [-o output_name]"
  exit 1
}
add_center_option() {
    local file="$1"
    sed -i '/Reveal.initialize({/a\    center: false,' "$file"
}
while getopts ":i:o:" opt; do
  case $opt in
    i) input="$OPTARG" ;;
    o) output="$OPTARG" ;;
    *) usage ;;
  esac
done

# Check that input was provided
if [[ -z "$input" ]]; then
  usage
fi

if [ -z "$(which nbmerge)" ];then
    python -m pip install nbmerge
fi

new=merged.ipynb
nbmerge style.ipynb $input > $new
jq '.metadata.title = "DA Workshop"' $new > tmp.ipynb
mv tmp.ipynb $new

# Strip `.ipynb` suffix if present
input_base="${input%.ipynb}"


# Use provided output or fallback to input base
output="${output:-$input_base}"

# Run the conversion
jupyter-nbconvert "$new" --to slides \
    --TagRemovePreprocessor.enabled=True \
    --SlidesExporter.reveal_transition=fade \
    --TagRemovePreprocessor.remove_input_tags=hide_input \
    --SlidesExporter.reveal_theme=simple \
    --SlidesExporter.reveal_scroll=True \
    --output="$output"
rm -f $new
add_center_option ${output}.slides.html
echo "✅ Slides generated: ${output}.slides.html"
