	// By Weston(weston.wei@sidways.com)
			// Usage:
			// 1. 设置el: el: '#list_comment_form'
			// 将以下标签放在form表单内
			// 2. 错误信息：<span class="red text_error"></span>
			// 3. 计数：<p class="text_count" style="display:none">您正在输入<span></span>个字。</p>
			// <script type="text/javascript">
		 // <%#= render :partial => "comments/share/validator.js" %>
		 // $(function(){
		   // window.commentFormView = new CommentFormView({"show_text_count": true, "el": "#list_comment_form"});
		 // });
		// </script>
		

		var CommentFormView = Backbone.View.extend({
			options:{"show_text_count": false},
			initialize: function(options) {
				this.options = options;	
				this.el = this.options.el;	
				return this;
			},
			el: '#list_comment_form',
			errorEl: ".text_error",
			countEl: ".text_count",
			successEl: ".text_success",
			minStrLen: 1,
			maxStrLen: 200,
				strCount: "", // 计数
				events: {
					"click a.btn_gray"  : "submit",
					// "keyup textarea" : "countText",
					'ajax:success'   : 'ajaxSuccess',
					'ajax:error'            : 'ajaxError'
				},
				ajaxSuccess: function(e, data, status, xhr){
					this.showSuccess("评论成功");
				},
				ajaxError: function(e, xhr, status, error){
					this.showError("评论失败");
				},
				submit: function(){
					this.showError('');
					this.showSuccess('');
					var str = this.$('textarea').val();
					if(this.isEmpty(str) || this.isBlank(str))
					{
						this.showError("评论不能为空");
						return;
					}
					else
					{
						$(this.el).submit();
					}
				},
				// 显示错误
				showError: function(str){
					if($(this.el).find(this.errorEl).length > 0){
						this.$(this.errorEl).text(str);
					}
				},
				// 显示成功
				showSuccess: function(str){
					// alert('...');
					if($(this.el).find(this.successEl).length > 0){
						this.$(this.successEl).text(str);
					}
				},
				// 计数
				countText: function(event){
					this.showError('');
					this.showSuccess('');
					str = $(this.el).find('textarea').val();
					if(str == "")
						return;
					this.strCount = this.getStrleng(str);
					//是否显示
					// if(this.options.show_text_count)
					// 	this.setTextCount(this.strCount);
				},
				getStrleng: function(str) {
					var r= new RegExp(
					    '[A-Za-z0-9_\]+|'+                             // ASCII letters (no accents)
					    '[\u3040-\u309F]+|'+                           // Hiragana
					    '[\u30A0-\u30FF]+|'+                           // Katakana
					    '[\u4E00-\u9FFF\uF900-\uFAFF\u3400-\u4DBF]',   // Single CJK ideographs
					    'g');
					var nwords= str.match(r).length;
					return nwords;
				},
				setTextCount: function(count){
					// $(this.el).find(this.countEl).show();
					// $(this.el).find(this.countEl + ' span').text(count);
				},
				isEmpty: function(str) {
				    return (!str || 0 === str.length);
				},
				isBlank: function(str) {
				    return (!str || /^\s*$/.test(str));
				}

			});
