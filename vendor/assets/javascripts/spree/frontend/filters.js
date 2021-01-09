$('.accordion-panel__header').click(function (event) {
  console.log(1);
  $(this).closest('.accordion__item').toggleClass('accordion__item--active react-plp-app-product-filters__accordion__item--active');
});
