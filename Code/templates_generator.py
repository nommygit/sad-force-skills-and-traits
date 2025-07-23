#!/usr/bin/env python3
"""
Generates Templates.lua file from Lua template definitions in Templates folder.

This script scans all .lua files in the Templates directory and generates a single
Templates.lua file containing all templates in a format that can be used to dynamically
create PlaceObj calls at runtime. Each template is stored with its filename as the key,
and contains an array of objects with 'class' and 'args' fields that can be passed to
PlaceObj to recreate the original template definitions.

If you use VS Code you can right-click 'Run Python File in Terminal' to rebuild Templates.lua.
Might need python language extension to do so.

Lovingly written by DeepSeek AI
"""

import os
import re
from pathlib import Path

# Change current working directory to script directory
os.chdir(Path(__file__).resolve().parent)

def generate_templates_lua_string(templates_dir='Templates'):
	templates_path = Path(templates_dir)
	if not templates_path.is_dir():
		raise FileNotFoundError(f"Directory not found: {templates_dir}")

	placeobj_re = re.compile(
		r"PlaceObj\(\s*'(?P<class>[^']+)'\s*,\s*\{(?P<args>[\s\S]*?)\}\s*\)",
		re.MULTILINE
	)

	template_entries = {}
	for lua_file in sorted(templates_path.glob('*.lua')):
		key = lua_file.stem
		text = lua_file.read_text(encoding='utf-8')
		# strip leading "return" block if present
		body = re.sub(r"^.*?return\s*{", "{", text, flags=re.DOTALL)
		body = body.rsplit("}", 1)[0] + "}"

		items = []
		for m in placeobj_re.finditer(body):
			cls = m.group('class')
			args = m.group('args').strip()

			# Clean up the arguments
			args = re.sub(r"\{\s*,", "{", args)  # Remove commas after opening braces
			args = re.sub(r",\s*\}", "}", args)  # Remove commas before closing braces
			args = re.sub(r",\s*$", "", args)    # Remove trailing commas
			
			# Process each line
			lines = []
			for line in args.splitlines():
				line = line.strip()
				if not line:
					continue
				if line.endswith(','):
					line = line[:-1]
				lines.append(line)
			
			# Join lines with proper indentation
			formatted_args = ",\n".join(lines)
			
			# Remove comma after opening brace
			formatted_args = formatted_args.replace("{,", "{")
			
			items.append(f"{{ class = '{cls}', args = {{\n{formatted_args}\n}} }}")

		template_entries[key] = items

	# Build the content as a string
	content_lines = [
		"--[[",
		"AUTO-GENERATED CODE  DON'T EDIT DIRECTLY",
		"",
		"This code was created by templates_generator.py based upon template files in the Templates folder.",
		"]]",
		"FSaT_Templates = {",
		""
	]

	for key, items in template_entries.items():
		content_lines.append(f"-- {key}.lua")
		content_lines.append("")
		content_lines.append(f"['{key}'] = {{")
		content_lines.append(",\n".join(items))
		content_lines.append("},")
		content_lines.append("")

	content_lines.append("}")

	return "\n".join(content_lines)

def lua_pretty_formatter(code: str) -> str:
	lines = code.splitlines()
	output_lines = []
	current_indent = 0
	in_block_comment = False

	for line in lines:
		stripped = line.strip()
		
		# Handle block comments
		if in_block_comment:
			output_lines.append('\t' * current_indent + stripped)
			if ']]' in stripped:
				in_block_comment = False
			continue

		if stripped.startswith('--[['):
			in_block_comment = True
			output_lines.append('\t' * current_indent + stripped)
			continue

		# Skip empty lines but preserve them
		if not stripped:
			output_lines.append('')
			continue

		# Count leading closing braces
		leading_closing = 0
		for c in stripped:
			if c == '}':
				leading_closing += 1
			elif c in (' ', '\t'):
				continue
			else:
				break

		# Adjust indent for leading closing braces
		if leading_closing > 0:
			current_indent = max(0, current_indent - leading_closing)

		# Add current indent to line
		output_lines.append('\t' * current_indent + stripped)

		# Update indent level for next line
		open_braces = stripped.count('{')
		close_braces = stripped.count('}') - leading_closing
		current_indent = max(0, current_indent + open_braces - close_braces)

	return '\n'.join(output_lines)

def write_string_to_file(content: str, output_file: str):
	with open(output_file, 'w', encoding='utf-8') as f:
		f.write(content)

def generate_templates_lua(templates_dir='Templates', output_file='Templates.lua'):
	content = generate_templates_lua_string(templates_dir)
	formatted_content = lua_pretty_formatter(content)
	write_string_to_file(formatted_content, output_file)

if __name__ == '__main__':
	generate_templates_lua()