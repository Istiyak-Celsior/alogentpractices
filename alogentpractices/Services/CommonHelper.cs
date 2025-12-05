using Azure;

namespace alogentpractices.Services
{
    public class CommonHelper
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CommonHelper(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private HttpResponse Response => _httpContextAccessor.HttpContext.Response;

        public void Break(string n)
        {
            Response.WriteAsync("<pre>" + n + "</pre>").Wait();
            Response.Body.FlushAsync().Wait();
            Response.CompleteAsync().Wait();
        }

        public string EscapeJSStr(string inStr)
        {
            if (string.IsNullOrEmpty((inStr ?? "").Trim())) return null;
            return inStr.Replace("'", "\\'");
        }

        public string DbFormatId(string strId)
        {
            if (string.IsNullOrEmpty((strId ?? "").Trim()))
            {
                return "NULL";
            }
            else
            {
                return "'" + strId.Trim() + "'";
            }
        }

        public string GetDocumentTypeIcon(string nFileName)
        {
            if (string.IsNullOrEmpty((nFileName ?? "").Trim()))
            {
                return "Content/Images/Icons/pixel.gif";
            }
            else
            {
                string pstrOut = "";
                string[] fileNameAry = nFileName.ToLower().Split('.');
                string lastInArray = fileNameAry[fileNameAry.Length - 1];

                if (lastInArray == "ppt" || lastInArray == "pptx")
                {
                    pstrOut = "fa-file-powerpoint";
                }
                else if (lastInArray == "xls" || lastInArray == "xlsx" || lastInArray == "csv")
                {
                    pstrOut = "fa-file-excel";
                }
                else if (lastInArray == "doc" || lastInArray == "docx")
                {
                    pstrOut = "fa-file-word";
                }
                else if (lastInArray == "txt")
                {
                    pstrOut = "fa-file-alt";
                }
                else if (lastInArray == "xml")
                {
                    pstrOut = "fa-file-code";
                }
                else if (lastInArray == "pdf")
                {
                    pstrOut = "fa-file-pdf";
                }
                else if (lastInArray == "tif" || lastInArray == "tiff")
                {
                    pstrOut = "fa-file-image";
                }
                else if (lastInArray == "xsn")
                {
                    pstrOut = "fa-file-code";
                }
                else
                {
                    pstrOut = "fa-file";
                }
                return "aa-file-type-icon fad " + pstrOut + " fa-fw";
            }
        }

        public string GetDocumentFileViewUrl(string documentId, string userId)
        {
            return $"document({documentId})/file?dispositionType=inline&userId={userId}";
        }
    }
}
