$(document).ready(function() {
  return $(".episodes").infinitescroll({
    loading: {
      msg: $('<em></em>')
    },
    navSelector: "nav.pagination",
    nextSelector: "nav.pagination a[rel=next]",
    itemSelector: ".episodes .episode"
  });
});


