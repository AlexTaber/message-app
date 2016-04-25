$(document).ready(function() {
  var presenceChannel;

  presenceChannel = pusher.subscribe("presence-user-" + userId);

  presenceChannel.bind("alert", function(data) {
    var notice;
    notice = new PNotify({
      title: data.title,
      text: data.text,
      type: data.type || 'alert',
      icon: null,
      desktop: {
        desktop: true,
        icon: "https://www.honeybadger.io/images/icon.png",
        tag: data.title + ":" + data.url
      }
    });

    if (data.url) {
      return notice.get().click(function() {
        if (notice.state === 'open') {
          return window.open(data.url);
        }
      });
    }
  });
});