#!/usr/bin/env bash

jupyter-nbconvert $1 --to slides \
    --TagRemovePreprocessor.enabled=True \
    --SlidesExporter.reveal_transition=fade \
    --TagRemovePreprocessor.remove_input_tags=hide_input \
    --SlidesExporter.reveal_theme=blood
