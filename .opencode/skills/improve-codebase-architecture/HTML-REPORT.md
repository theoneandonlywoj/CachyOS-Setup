# HTML Report Scaffold

Use this as a starting point for the architecture review report.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Architecture Review</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
</head>
<body class="bg-gray-50 text-gray-900 p-8">
  <div class="max-w-4xl mx-auto">
    <h1 class="text-3xl font-bold mb-6">Architecture Review</h1>
    <p class="mb-8 text-gray-600">Generated on <span id="date"></span></p>

    <!-- Candidate card -->
    <div class="bg-white rounded-lg shadow p-6 mb-6">
      <div class="flex items-start justify-between">
        <h2 class="text-xl font-semibold">Candidate title</h2>
        <span class="px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">Strong</span>
      </div>
      <p class="text-gray-600 mt-2">Files: ...</p>
      <h3 class="font-semibold mt-4">Problem</h3>
      <p>...</p>
      <h3 class="font-semibold mt-4">Solution</h3>
      <p>...</p>
      <h3 class="font-semibold mt-4">Benefits</h3>
      <p>...</p>
      <div class="grid grid-cols-2 gap-4 mt-4">
        <div class="border rounded p-4">
          <h4 class="font-semibold mb-2">Before</h4>
          <!-- Mermaid or custom diagram -->
        </div>
        <div class="border rounded p-4">
          <h4 class="font-semibold mb-2">After</h4>
          <!-- Mermaid or custom diagram -->
        </div>
      </div>
    </div>

    <!-- Top recommendation -->
    <div class="bg-blue-50 border border-blue-200 rounded-lg p-6">
      <h2 class="text-xl font-semibold mb-2">Top recommendation</h2>
      <p>...</p>
    </div>
  </div>
  <script>mermaid.initialize({ startOnLoad: true }); document.getElementById('date').textContent = new Date().toLocaleString();</script>
</body>
</html>
```

## Badge colors

- `Strong` — red
- `Worth exploring` — yellow
- `Speculative` — gray

## Diagrams

Use Mermaid for graph-shaped relationships. Use hand-built divs/SVG for editorial visuals. Always label diagrams in `CONTEXT.md` vocabulary.
