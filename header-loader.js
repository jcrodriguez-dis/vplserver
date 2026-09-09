document.querySelectorAll('[data-include]').forEach(async (container) => {
    const includePath = container.dataset.include;
    const rootPath = container.dataset.root || '';

    try {
        const response = await fetch(includePath);
        if (!response.ok) {
            throw new Error(`Could not load ${includePath}`);
        }
        const fragment = await response.text();
        container.outerHTML = fragment.replaceAll('{{ROOT}}', rootPath);
    } catch (error) {
        container.textContent = 'The navigation could not be loaded.';
        console.error(error);
    }
});
