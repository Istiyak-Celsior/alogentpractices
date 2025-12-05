let RssFeedController = (function ($, rssXml, uiElements) {
    let publicApi = {
        isLoaded: false
    };

    publicApi.load = function () {
        initializeGrid();
        publicApi.isLoaded = true;
    };

    function initializeGrid() {
        if (rssXml + '' === '') {
            let errorMessage = '<span id="rss-error"><i class="fas fa-exclamation-triangle" aria-hidden="true"></i>&nbsp;&nbsp;Retrieval of the RSS Feed returned an error.</span>';
            $(uiElements.feedGrid).html(errorMessage);
            return;
        }

        let feedItemDS = new kendo.data.DataSource({
            type: 'xml',
            data: rssXml.replace(/&apos;/g, "'").replace(/&quot;/g, '"').replace(/&gt;/g, '>').replace(/&lt;/g, '<').replace(/&amp;/g, '&'),
            schema: {
                type: 'xml',
                data: '/rss/channel/item',
                model: {
                    id: 'guid',
                    fields: {
                        title: 'title/text()',
                        pubDate: 'pubDate/text()',
                        story: 'description/text()',
                        url: 'link/text()',
                        id: 'guid/text()'
                    }
                }
            },
            pageSize: 4
        });

        $(uiElements.feedGrid).kendoGrid({
            dataSource: feedItemDS,
            height: 603,
            groupable: false,
            sortable: false,
            scrollable: true,
            pageable: {
                pageSize: 4,
                buttonCount: 1
            },
            dataBound: function (e) {
                adjustDom();
            },
            columns: [
                {
                    title: 'Title',
                    field: 'story',
                    encoded: false,
                    template: kendo.template($(uiElements.feedRowTemplate).html())
                }
            ]
        });
    }

    return publicApi;
});

function adjustDom() {
    /* HIDE KENDO GRID HEADER */
    $('.k-grid .k-grid-header').hide();
    /* REMOVE REPEATED URL PARAGRAPH FROM FEED */
    $('a[rel="nofollow"]').closest('p').remove();
}

function articleDate(articleDate) {
    let todayDate = new Date();
    let thisDate = new Date(articleDate);
    let options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };

    let diff = numDaysBetween(todayDate, thisDate).toFixed(0);
    let newString = diff < 7 ? '<span class="new">NEW</span> ' : '';

    return '<p>' + newString + thisDate.toLocaleDateString("en-US", options) + '</p>';
}

function numDaysBetween(date1, date2) {
    let diff = Math.abs(date1.getTime() - date2.getTime());
    return diff / (1000 * 60 * 60 * 24);
}