####################
bootstrap tab插件，通过链接访问不同的页面
#####################
<div class="container body-content">
	<ul class="nav nav-tabs">
		<li class="active"><a data-toggle="tab" href="#inbox">Inbox</a></li>
		<li><a data-toggle="tab" href="#outbox">Outbox</a></li>
		<li><a data-toggle="tab" href="#compose">Compose</a></li>
	</ul>
	<div class="tab-content">
		<div id="inbox" class="tab-pane fade in active">
			Inbox Content
		</div>
		<div id="outbox" class="tab-pane fade">
			Outbox Content
		</div>
		<div id="compose" class="tab-pane fade">
			Compose Content
		</div>
	</div>
</div>
<script>
	$(function () {
		var hash = window.location.hash;
		hash && $('ul.nav a[href="' + hash + '"]').tab('show');
	});
</script>


######################
单击一图标，显示和隐藏下面的div
######################
<script>
	$('body').on('click', '.overlap > .over_title > .tools > .collapse, .overlap > .over_title > .tools > .expand', function(e) {
		e.preventDefault();
		var el = $(this).closest(".overlap").children(".over_form");
		if ($(this).hasClass("collapse")) {
			$(this).removeClass("collapse").addClass("expand");
			el.slideUp(200);
		} else {
			$(this).removeClass("expand").addClass("collapse");
			el.slideDown(200);
		}
	});
</script>
<div class="overlap">
	<div class="over_title">
		<div class="caption">
		<p>Analyze overlap genes</p>
		</div>
		<div class="tools" id="tools">
			<a href="javascript:;" class="collapse" data-original-title="" title="" style=""></a>
		</div>
	</div>

	<div class="over_form" style="">
  </div>
</div>


###################

###################

