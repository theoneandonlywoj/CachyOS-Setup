#!/usr/bin/env fish
# === plantuml.fish ===
# Purpose: Install PlantUML diagramming tool on CachyOS
# Installs PlantUML from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting PlantUML installation..."

# === 1. Check if PlantUML is already installed ===
command -q plantuml; and set -l plantuml_installed "installed"
if test -n "$plantuml_installed"
    echo "✅ PlantUML is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping PlantUML installation."
        exit 0
    end
    echo "📦 Removing existing PlantUML installation..."
    sudo pacman -R --noconfirm plantuml
    if test $status -ne 0
        echo "❌ Failed to remove PlantUML."
        exit 1
    end
    echo "✅ PlantUML removed."
end

# === 2. Install Java (required for PlantUML) ===
echo "📦 Checking for Java..."
command -q java; and set -l java_installed "installed"
if test -z "$java_installed"
    echo "⚠ Java is not installed (required for PlantUML)."
    read -P "Do you want to install Java? [Y/n] " install_java
    if test "$install_java" != "n" -a "$install_java" != "N"
        echo "📦 Installing Java..."
        sudo pacman -S --needed --noconfirm jdk-openjdk
        if test $status -ne 0
            echo "❌ Failed to install Java."
            exit 1
        end
        echo "✅ Java installed."
    else
        echo "❌ Java is required for PlantUML."
        exit 1
    end
else
    echo "✅ Java is installed."
    java -version 2>&1 | head -n 1
end

# === 3. Install PlantUML ===
echo "📦 Installing PlantUML..."
sudo pacman -S --needed --noconfirm plantuml
if test $status -ne 0
    echo "❌ Failed to install PlantUML."
    exit 1
end
echo "✅ PlantUML installed."

# === 4. Install optional PlantUML extensions ===
echo "📦 Installing optional PlantUML extensions..."
echo "💡 The following packages enhance PlantUML capabilities:"
echo "   - plantuml-ascii-math: AsciiMath and JLaTeXMath support"
echo "   - graphviz: For more complex diagrams"
read -P "Do you want to install optional extensions? [y/N] " install_extensions

if test "$install_extensions" = "y" -o "$install_extensions" = "Y"
    echo "📦 Installing PlantUML extensions..."
    sudo pacman -S --needed --noconfirm plantuml-ascii-math graphviz
    if test $status -ne 0
        echo "⚠ Failed to install some extensions, but PlantUML is still installed."
    else
        echo "✅ PlantUML extensions installed."
    end
end

# === 5. Check and fix snapper Boost library issue (if present) ===
if test -f /usr/bin/snapper
    echo
    echo "🔧 Checking for snapper Boost library issue..."
    snapper --version > /dev/null 2>&1
    if test $status -ne 0
        echo "⚠ Detected snapper Boost library version mismatch."
        echo "💡 This can happen after Boost updates."
        read -P "Do you want to fix snapper? [y/N] " fix_snapper
        
        if test "$fix_snapper" = "y" -o "$fix_snapper" = "Y"
            echo "📦 Reinstalling snapper to fix Boost library version mismatch..."
            sudo pacman -S --noconfirm snapper
            if test $status -eq 0
                echo "✅ Snapper fixed successfully."
            else
                echo "⚠ Failed to fix snapper, but PlantUML is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q plantuml
if test $status -eq 0
    echo "✅ PlantUML installed successfully"
    plantuml -version 2>&1 | head -n 1
else
    echo "❌ PlantUML installation verification failed."
end

echo
echo "✅ PlantUML installation complete!"
echo "💡 PlantUML is a text-based UML diagramming tool:"
echo "   - Create diagrams from plain text"
echo "   - Sequence diagrams, class diagrams, use case diagrams"
echo "   - Activity diagrams, state diagrams, component diagrams"
echo "   - Export to PNG, SVG, PDF, or LaTeX"
echo "💡 Usage examples:"
echo "   - Create diagram: plantuml file.puml"
echo "   - PNG output: plantuml -tpng file.puml"
echo "   - SVG output: plantuml -tsvg file.puml"
echo "   - PNG with LaTeX: plantuml -tpng -nometadata file.puml"
echo "💡 Basic diagram syntax:"
echo "   @startuml"
echo "   Alice -> Bob: Hello"
echo "   Bob -> Alice: Hi"
echo "   @enduml"
echo "💡 Common diagram types:"
echo "   - Sequence: @startuml (default is sequence)"
echo "   - Class: @startclass"
echo "   - Activity: @startactivity"
echo "   - State: @startstate"
echo "💡 Tips:"
echo "   - Use VS Code with PlantUML extension for live preview"
echo "   - Add !theme to change diagram theme"
echo "   - Use include/import for large diagrams"
echo "   - Generate from Markdown with Mermaid or PlantUML"
echo "💡 Resources:"
echo "   - Documentation: http://plantuml.com"
echo "   - Syntax reference: http://plantuml.com/guide"

