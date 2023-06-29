const calcHeight = elem => {
  const elemHeight = elem.offsetHeight + parseInt(getComputedStyle(elem).paddingBottom);
  const height = Math.max(elemHeight, window.innerHeight);

  return `${height}px`;
};

function handleImageClick(src) {
  const anchor = document.getElementById(`${src}-popup`);
  anchor.style.height = calcHeight(document.body);

  const popupImgContainer = anchor.firstElementChild;
  popupImgContainer.style.top = `${window.scrollY}px`;

  anchor.classList.replace('hidden', 'visible');
}

function handleImageHide(src) {
  const anchor = document.getElementById(`${src}-popup`);
  anchor.classList.replace('visible', 'hidden');
}
