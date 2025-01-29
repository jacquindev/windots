vagrant_completion_file="$(find "/c/Program Files/Vagrant" -type f -name 'completion.sh' | head -n 1)"
if [[ -f "$vagrant_completion_file" ]]; then
	source "$vagrant_completion_file"
fi
