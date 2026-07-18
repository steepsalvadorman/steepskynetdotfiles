#!/usr/bin/env python3
import os
import sys
import json
import glob
import re

def get_desktop_files():
    paths = [
        '/usr/share/applications',
        os.path.expanduser('~/.local/share/applications')
    ]
    files = []
    for path in paths:
        if os.path.exists(path):
            files.extend(glob.glob(os.path.join(path, '*.desktop')))
    return files

def parse_desktop_file(filepath):
    app = {}
    try:
        with open(filepath, 'r', errors='ignore') as f:
            content = f.read()
        
        # We only care about the [Desktop Entry] section
        entry_match = re.search(r'\[Desktop Entry\](.*?)(?=\n\[|$)', content, re.DOTALL)
        if not entry_match:
            return None
        
        entry = entry_match.group(1)
        
        # Check if NoDisplay=true
        nodisplay = re.search(r'^NoDisplay\s*=\s*(true|1)', entry, re.IGNORECASE | re.MULTILINE)
        if nodisplay:
            return None
            
        # Check if Type=Application
        app_type = re.search(r'^Type\s*=\s*Application', entry, re.IGNORECASE | re.MULTILINE)
        if not app_type:
            return None
            
        # Get Name
        name_match = re.search(r'^Name\s*=\s*(.*)', entry, re.MULTILINE)
        if name_match:
            app['name'] = name_match.group(1).strip()
        else:
            return None
            
        # Get Exec
        exec_match = re.search(r'^Exec\s*=\s*(.*)', entry, re.MULTILINE)
        if exec_match:
            exec_str = exec_match.group(1).strip()
            # Strip fields like %u, %F, %U
            exec_str = re.sub(r'%[fFuUrRdiIkKmu]', '', exec_str).strip()
            app['exec'] = exec_str
        else:
            return None
            
        # Get Icon
        icon_match = re.search(r'^Icon\s*=\s*(.*)', entry, re.MULTILINE)
        if icon_match:
            app['icon'] = icon_match.group(1).strip()
        else:
            app['icon'] = 'system-run'
            
        # Get Comment
        comment_match = re.search(r'^Comment\s*=\s*(.*)', entry, re.MULTILINE)
        if comment_match:
            app['comment'] = comment_match.group(1).strip()
        else:
            app['comment'] = ''
            
        return app
    except Exception:
        return None

def main():
    apps = []
    seen_execs = set()
    for f in get_desktop_files():
        app = parse_desktop_file(f)
        if app:
            key = (app['name'].lower(), app['exec'].lower())
            if key not in seen_execs:
                seen_execs.add(key)
                apps.append(app)
                
    # Sort alphabetically
    apps.sort(key=lambda x: x['name'].lower())
    print(json.dumps(apps))

if __name__ == '__main__':
    main()
