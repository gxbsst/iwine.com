$(function(){

    window.StarsView = Backbone.View.extend({
        initialize: function() {
            self = this
            _.each([1, 2, 3, 4, 5], function(num){
                self.addOne(num);
            });
            return this;
        },
        addOne: function(num) {
            var view = new StarItemView(num);
            $("ul#stars").append(view.render(num).el);
        },
        setDefaultRateStar: function(){
            var default_num = this.itemView.input.val();
            var items = $(this.el).find("ul").children();
            _.each(items, function(item){
                $(item).find("img").attr("src", "/assets/base/star_gray.jpg");
            });

        }
    });

    window.StarItemView = Backbone.View.extend({
        input: $("input[name='rate_value']"),
        tagName: 'li',
        template: _.template($('#star_item').html()),
        textValue: ['欠佳',   '可接受','出色','非常不错','质量一流'],
        events: {
            "mouseover .star img"  : "changeStarColorAsYellow",
            'mouseleave .star img': 'initializeRateValue',
            "click .star img"  : "setStarRate"

        },
        initialize: function() {
        },

        render: function(num) {
            $(this.el).attr("id", "star_" + num).addClass("star").html(this.template());
            this.setText();
            return this;
        },
        setStarRate: function() {
            var num = $(this.el).attr("id").split("_")[1];
            this.setInputValue(num);
            this.showColorStar(nub, "red");
        },
        // mouseover 鼠标滑进时
        changeStarColorAsYellow: function() {
            this.showColorStar(5, "gray");
            // 设星
            var num = $(this.el).attr("id").split("_")[1];
            this.showColorStar(num, "yellow");
            // 设文
            this.setText(num);
        },
        setInputValue: function(value){
            this.input.val(value);
        },
        // 鼠标离开星星时，默认显示原来的值
        initializeRateValue: function() {
            var num = 5;
            this.showColorStar(num, "gray");
            var num = this.input.val();
            this.showColorStar(num, "red");
        },
        starSrc: function(color){
            return "/assets/base/star_" + color +".jpg";
        },
        // end: 为显示几个星星
        // color: 显示什么颜色
        showColorStar: function(end, color){
            var self = this;
            var items = $(this.el).parent().children().slice(0, end);
            _.each(items, function(item){
                $(item).find("img").attr("src", self.starSrc(color));
            });
        },
        remove: function() {
            $(this.el).remove();
        },
        clear: function() {
            // this.model.destroy();
        },
        setText: function(num) {
            $(".text_value").text(this.textValue[num]);
        }
    });

    window.StarApp = new StarsView({el:$("#wine_profile_star_bar")});
    StarApp.itemView = new StarItemView();
    StarApp.setDefaultRateStar();
});


