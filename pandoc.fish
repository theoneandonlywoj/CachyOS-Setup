#!/usr/bin/env fish
# === pandoc.fish ===
# Purpose: Install Pandoc (universal document converter) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Pandoc installation..."
echo
echo "💡 Pandoc is a universal document converter:"
echo "   - Convert between markup formats (Markdown, HTML, LaTeX, etc.)"
echo "   - Support for 40+ input and output formats"
echo "   - Generate PDFs, EPUBs, and more"
echo "   - Extensible with filters and templates"
echo "   - Widely used in academic and technical writing"
echo

# === 1. Check if Pandoc is already installed ===
command -q pandoc; and set -l pandoc_installed "installed"
if test -n "$pandoc_installed"
    echo "✅ Pandoc is already installed."
    pandoc --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Pandoc installation."
        exit 0
    end
    echo "📦 Removing existing Pandoc installation..."
    # Try to remove via pacman if installed via pacman
    if pacman -Qq pandoc > /dev/null 2>&1
        sudo pacman -R --noconfirm pandoc
        if test $status -eq 0
            echo "✅ Pandoc removed via pacman."
        else
            echo "⚠ Warning: Failed to remove Pandoc via pacman."
            echo "   You may need to remove it manually."
        end
    else
        echo "⚠ Pandoc is not installed via pacman."
        echo "   It may have been installed via pip or another method."
        echo "   Please remove it manually if needed."
    end
end

# === 2. Install Pandoc ===
echo "📦 Installing Pandoc from official repository..."
sudo pacman -S --needed --noconfirm pandoc
if test $status -ne 0
    echo "❌ Failed to install Pandoc."
    exit 1
end
echo "✅ Pandoc installed."

# === 3. Install recommended LaTeX packages for PDF generation ===
echo "📦 Installing recommended LaTeX packages for PDF generation..."
echo "💡 These are optional but recommended for PDF output:"
read -P "Do you want to install LaTeX packages? [y/N] " install_latex

if test "$install_latex" = "y" -o "$install_latex" = "Y"
    sudo pacman -S --needed --noconfirm texlive-core texlive-bin texlive-basic texlive-latex texlive-latexextra
    if test $status -eq 0
        echo "✅ LaTeX packages installed."
    else
        echo "⚠ Warning: Failed to install some LaTeX packages."
        echo "   Pandoc will still work, but PDF generation may be limited."
    end
else
    echo "ℹ Skipping LaTeX installation."
    echo "💡 You can install LaTeX later with:"
    echo "   sudo pacman -S --needed texlive-core texlive-bin texlive-basic"
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q pandoc
    echo "✅ Pandoc installed successfully"
    pandoc --version 2>&1 | head -n 1
else
    echo "❌ Pandoc installation verification failed."
    exit 1
end

echo
echo "🎉 Pandoc installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Convert Markdown to HTML"
echo "   pandoc input.md -o output.html"
echo ""
echo "   # Convert Markdown to PDF"
echo "   pandoc input.md -o output.pdf"
echo ""
echo "   # Convert Markdown to DOCX"
echo "   pandoc input.md -o output.docx"
echo ""
echo "   # Convert HTML to Markdown"
echo "   pandoc input.html -o output.md"
echo ""
echo "   # Convert with custom template"
echo "   pandoc input.md --template template.tex -o output.pdf"
echo ""
echo "💡 Common input formats:"
echo "   - Markdown (.md, .markdown)"
echo "   - HTML (.html, .htm)"
echo "   - LaTeX (.tex)"
echo "   - DocBook (.dbk)"
echo "   - MediaWiki"
echo "   - reStructuredText (.rst)"
echo "   - Textile"
echo "   - And 30+ more formats"
echo ""
echo "💡 Common output formats:"
echo "   - HTML (.html)"
echo "   - PDF (.pdf) - requires LaTeX or wkhtmltopdf"
echo "   - DOCX (.docx)"
echo "   - EPUB (.epub)"
echo "   - LaTeX (.tex)"
echo "   - Markdown (.md)"
echo "   - RTF (.rtf)"
echo "   - And 30+ more formats"
echo ""
echo "💡 Advanced usage:"
echo "   # Convert with syntax highlighting"
echo "   pandoc code.md --highlight-style pygments -o output.html"
echo ""
echo "   # Convert with table of contents"
echo "   pandoc document.md --toc -o output.html"
echo ""
echo "   # Convert with custom CSS"
echo "   pandoc document.md -c style.css -o output.html"
echo ""
echo "   # Convert with metadata"
echo "   pandoc document.md --metadata title=\"My Document\" -o output.html"
echo ""
echo "   # Convert multiple files"
echo "   pandoc chapter1.md chapter2.md -o book.pdf"
echo ""
echo "   # Convert from stdin to stdout"
echo "   echo '# Hello' | pandoc -f markdown -t html"
echo ""
echo "💡 PDF generation:"
echo "   # Using LaTeX (default, requires texlive)"
echo "   pandoc document.md -o document.pdf"
echo ""
echo "   # Using wkhtmltopdf"
echo "   pandoc document.md -o document.pdf --pdf-engine=wkhtmltopdf"
echo ""
echo "   # Using WeasyPrint"
echo "   pandoc document.md -o document.pdf --pdf-engine=weasyprint"
echo ""
echo "💡 Filters and extensions:"
echo "   # Use a filter"
echo "   pandoc document.md --filter pandoc-citeproc -o output.pdf"
echo ""
echo "   # Enable GitHub-flavored Markdown"
echo "   pandoc document.md -f gfm -t html -o output.html"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://pandoc.org/"
echo "   - Documentation: https://pandoc.org/MANUAL.html"
echo "   - Getting started: https://pandoc.org/getting-started.html"
echo "   - Examples: https://pandoc.org/demos.html"
echo "   - Templates: https://github.com/jgm/pandoc/wiki/User-contributed-templates"

