var PlaceholderVisualizer = (function ($, kendo, undefined) {

    const HtmlExpression = /<template-placeholder\s+[^>]*data-identifier="([^"]+)"[^>]*>[\s\S]*?<\/template-placeholder>/gis;
    const TextExpression = /\[placeholder:\s*([a-f0-9\-]{36})\]/gis;

    return kendo.Class.extend({
       createPlaceholderElement: function(editor, dataItem) {      
           let placeholder     = dataItem;
           let placeholderHtml = kendo.template($("#noticeplaceholder-template").html())(placeholder);
   
           placeholderHtml = placeholderHtml.trim();
   
           editor.paste(placeholderHtml, true);
   
           setTimeout(() => {
               editor.focus();
   
               let range = editor.getRange();
               let parentNode = range.endContainer.parentNode;
               
               range.selectNode(parentNode);
               range.collapse();
   
               editor.selectRange(range);
           });
       },
       devisualizeText: function(text) {
        
           let visualizedText = text.replace(HtmlExpression, (match, p1) => {
               let placeholderHtml = `[placeholder: ${p1}]`;

               return placeholderHtml;
           });

           return visualizedText;
       },
       visualizeText: function(text, placeholders) {

           let visualizedText = text.replace(TextExpression, (match, p1) => {
               var placeholder = placeholders.find(p => p.id == p1);

               if (placeholder) {
                   let placeholderTemplate = $("#noticeplaceholder-template").html();
                   let placeholderHtml     = kendo.template(placeholderTemplate)(placeholder);
                   let cleanHtml           = placeholderHtml.trim();
                   
                   return cleanHtml;
               }
               
               return match;
           });

           return visualizedText;      
       },
    });

})(window.kendo.jQuery, window.kendo, undefined);