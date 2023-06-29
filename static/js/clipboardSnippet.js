document.querySelectorAll('p code').forEach(e => {
  const text = e.childNodes[0].textContent;
  e.addEventListener('click', () => {
    navigator.clipboard.writeText(text);
    e.childNodes[1].textContent = 'OK';
  });

  e.addEventListener('mouseout', () => {
    e.childNodes[1].textContent = 'Copy';
  });

  const tooltip = document.createElement('span');
  tooltip.classList.add('tooltip');
  tooltip.innerText = 'Copy';

  e.appendChild(tooltip);
});

document.querySelectorAll('article pre').forEach(e => {
  const buttonContainer = document.createElement('div');
  buttonContainer.classList.add('button-container');
  const button = document.createElement('button');
  button.innerText = 'Copy code';
  button.addEventListener('click', () => {
    let text = '';
    const tableListing = e.querySelectorAll('table tr td:not(:first-child)');
    const regularListing = e.querySelector('code');

    if (!tableListing.length) {
      text = regularListing.innerText;
    } else {
      e.querySelectorAll('table tr td:not(:first-child)').forEach(f => {
        text += f.textContent;
      });
    }

    navigator.clipboard.writeText(text);
  });

  buttonContainer.appendChild(button);
  e.appendChild(buttonContainer);
});
