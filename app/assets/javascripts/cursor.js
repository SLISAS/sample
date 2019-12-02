$(function() {
  //マウスが置かれたらclass「on_mouse」を追加、外れたら「on_mouse」を削除
  $(".change2")
    .on("mouseover", function() {
      $(this).addClass("on_mouse");
    })
    .on("mouseout", function() {
      $(this).removeClass("on_mouse");
    });

  //マウスの位置にあわせて画像のCSSを指定
  function mouseMove(e) {
    $(".change2 img").css({
      top: e.clientY,
      left: e.clientX
    });
  }
  $(".change2").on("mousemove", mouseMove);
});
