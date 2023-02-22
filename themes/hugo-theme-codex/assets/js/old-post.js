const postDate = Date.parse(
  document.querySelector(".post__date").getAttribute("datetime"),
);

const difference = Date.now() - postDate;

// if the post is older than 6 months, show a warning
if (difference > 15768000000) {
  document.querySelector(".post__warning").style.display = "inline";
}
