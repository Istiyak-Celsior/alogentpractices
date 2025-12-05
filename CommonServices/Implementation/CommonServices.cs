using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Text;

namespace ServiceLayer.Implementation
{
    public class Common
    {
        private readonly IHttpContextAccessor _contextAccessor;
        private readonly string _connectionString;

        public Common(IHttpContextAccessor contextAccessor, string connectionString)
        {
            _contextAccessor = contextAccessor;
            _connectionString = connectionString;
        }

        public void ExecuteCommand(string sql, int timeout)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand(sql, conn))
                {
                    command.CommandType = CommandType.Text;
                    command.CommandTimeout = timeout;
                    conn.Open();
                    command.ExecuteNonQuery();
                }
            }
        }

        public HttpResponseMessage MailMessage(string from, string recipients, string subject, string body)
        {
            var client = new HttpClient();
            string url = _contextAccessor.HttpContext.Session.GetString("acculoan.serverURL") + "/mail/message";
            var request = new HttpRequestMessage(HttpMethod.Post, url);

            var data = "{\n" +
                      $"  \"From\": \"{from}\",\n" +
                      $"  \"Recipients\": {recipients},\n" +
                      $"  \"Subject\": \"{subject.Replace("\"", "\\\"")}\",\n" +
                      $"  \"Body\": \"{body.Replace("\"", "\\\"")}\"\n" +
                      "}";

            request.Content = new StringContent(data, Encoding.UTF8, "application/json");
            return client.Send(request);
        }

        public HttpResponseMessage MailDocument(string from, string recipients, string subject, string body, Guid documentId)
        {
            var client = new HttpClient();
            var session = _contextAccessor.HttpContext.Session;
            string url = session.GetString("acculoan.serverURL") + $"/document({documentId})/mail";
            var data = BuildXMLMailMessage(from, recipients, subject, body);
            var request = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(data, Encoding.UTF8, "application/xml")
            };
            request.Headers.Accept.ParseAdd("application/xml");
            return client.Send(request);
        }

        public string BuildXMLMailMessage(string from, string recipients, string subject, string body)
        {
            return "<MailRequest></MailRequest>";
        }

        public string BuildXMLRecipientList(string sendTo)
        {
            var adjustedList = sendTo.Replace(",", ";").Split(';');
            var formattedList = new StringBuilder();
            foreach (var recipient in adjustedList)
            {
                formattedList.Append($"<string>{recipient}</string>");
            }
            return $"<Recipients>{formattedList}</Recipients>";
        }

        public string BuildRecipientList(string sendTo)
        {
            var adjustedList = sendTo.Replace(",", ";").Split(';');
            var quoted = string.Join(", ", adjustedList.Select(r => $"\"{r}\""));
            return $"[{quoted}]";
        }

        public bool IsEmptyArray(Array arr)
        {
            try
            {
                return arr == null || arr.Length == 0;
            }
            catch
            {
                return true;
            }
        }

        public bool IsDuplicateBarcodeKey(string keyValue)
        {
            bool result = false;
            string query = $"SELECT COUNT(*) AS cnt FROM documentDefinitions WHERE barcodeKey = {keyValue}";

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    int count = (int)cmd.ExecuteScalar();
                    result = count > 0;
                }
            }
            return result;
        }

        public string GetQuotedString(string value) => $"\"{value}\"";

        public object[,] EmptyRecordSetArray() => new object[1, 1];

        public string FormatFileSize(object sizeObj)
        {
            if (sizeObj == null || !double.TryParse(sizeObj.ToString(), out double size))
                return "Unknown";

            string label = "Kb";
            if (size >= 100)
            {
                size /= 1000.0;
                label = "Mb";
                if (size >= 100)
                {
                    size /= 1000.0;
                    label = "Gb";
                }
            }
            return string.Format("{0:0.00} {1}", size, label);
        }

        public string FormatFilenameTimestamp(string timestamp)
        {
            return timestamp.Replace(" ", "_").Replace("/", "-").Replace(":", "-");
        }

        public string GetCurrentUploadDirectory(string requestArg)
        {
            var context = _contextAccessor.HttpContext;
            string uploadDir = string.IsNullOrEmpty(requestArg) ? context.Request.Query["currentUploadDir"] : context.Request.Query[requestArg];

            if (string.IsNullOrEmpty(uploadDir))
            {
                uploadDir = context.Session.GetString("currentUploadDir") ?? context.Request.Cookies["acculoan.uploadDir"];
            }

            if (string.IsNullOrWhiteSpace(uploadDir) || uploadDir.Trim() == "\\")
            {
                var basePath = RemoveTrailingSlash(context.Session.GetString("uploadPath"));
                uploadDir = $"\\{basePath}\\{context.Session.GetString("userLogin")}";
            }

            return uploadDir;
        }

        public void SetCurrentUploadDirectory(string directory)
        {
            var context = _contextAccessor.HttpContext;
            context.Session.SetString("currentUploadDir", directory);
            context.Response.Cookies.Append("acculoan.uploadDir", directory, new CookieOptions
            {
                Expires = DateTime.Now.AddMonths(1)
            });
        }

        public string GetDataTypeLabel(string dataTypeName)
        {
            return dataTypeName switch
            {
                "bit" => "Boolean",
                "decimal" => "Decimal",
                "int" => "Integer",
                "datetime" => "Date/Time",
                "varchar" => "Text",
                "money" => "Currency",
                "choice" => "Choice List",
                _ => "Unknown"
            };
        }

        private string RemoveTrailingSlash(string path)
        {
            if (string.IsNullOrEmpty(path)) return path;
            return path.TrimEnd('\\');
        }
    }
}
