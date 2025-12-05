using System.Xml;
using System.Data;
using System.Data.SqlClient;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;

namespace DataAccessLayer.Code
{
    public class InitConfigService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public InitConfigService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public void InitializeSession()
        {
            var session = _httpContextAccessor.HttpContext.Session;

            if (string.IsNullOrEmpty(session.GetString("strconn")))
            {
                string configPath = Path.Combine(string.Empty, "xml", "config.xml");
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(configPath);

                string strconn = GetXmlTagValue(xmlDoc, "connection");
                string strconnAccuDoc = GetXmlTagValue(xmlDoc, "AccuDocConnection");
                string rptConn = GetXmlTagValue(xmlDoc, "ReportConnection");

                session. SetString("strconn", strconn);
                session.SetString("strconnAccuDoc", strconnAccuDoc);
                session.SetString("rptConn", rptConn);

                session.SetString("fullPath", GetXmlTagValue(xmlDoc, "fullPath"));
                session.SetString("serverPath", GetXmlTagValue(xmlDoc, "serverPath"));
                session.SetString("relativePath", GetXmlTagValueOrDefault(xmlDoc, "relativePath", "scanned_images/"));
                session.SetString("uploadPath", GetXmlTagValueOrDefault(xmlDoc, "uploadPath", "upload/"));
                session.SetString("logPath", GetXmlTagValueOrDefault(xmlDoc, "logPath", "logs/"));
                session.SetString("database", GetXmlTagValue(xmlDoc, "database"));
                session.SetString("databaseVersion", GetXmlTagValue(xmlDoc, "databaseVersion"));
                session.SetString("useGUID", GetXmlTagValue(xmlDoc, "useGUID"));
                session.SetString("auditPath", GetXmlTagValueOrDefault(xmlDoc, "auditPath", "audit/"));
                session.SetString("dbScanHistory", GetXmlTagValue(xmlDoc, "dbScanHistory"));
                session.SetString("barcodeScanYN", GetXmlTagValue(xmlDoc, "barcodeScanYN"));
                session.SetString("enableWindowsSecurityYN", GetXmlTagValue(xmlDoc, "enableWindowsSecurityYN")?.ToUpper());
                session.SetString("securityDomain", GetXmlTagValue(xmlDoc, "securityDomain"));

                session.SetString("externalDocs", NormalizePath(GetXmlTagValue(xmlDoc, "externalDocs")));
                session.SetString("VirtualShareDir", GetXmlTagValue(xmlDoc, "VirtualShareDir")?.ToUpper());
                session.SetString("UseBranchSecurity", GetXmlTagValueOrDefault(xmlDoc, "UseBranchSecurity", "N"));

                // Email settings
                session.SetString("email.sendUsing", GetXmlTagValue(xmlDoc, "sendUsing"));
                session.SetString("email.smtpPickupDirectory", GetXmlTagValue(xmlDoc, "smtpPickupDirectory"));
                session.SetString("email.smtpServer", GetXmlTagValue(xmlDoc, "smtpServer"));
                session.SetString("email.smtpPort", GetXmlTagValue(xmlDoc, "smtpPort"));
                session.SetString("email.smtpUseDefaultCredentials", GetXmlTagValue(xmlDoc, "smtpUseDefaultCredentials") ?? "false");
                session.SetString("email.smtpEnableSsl", GetXmlTagValue(xmlDoc, "smtpEnableSsl") ?? "false");
                session.SetString("email.smtpSender", GetXmlTagValue(xmlDoc, "smtpSender"));
                session.SetString("email.smtpUserName", GetXmlTagValue(xmlDoc, "smtpUserName"));
                session.SetString("email.smtpPassword", GetXmlTagValue(xmlDoc, "smtpPassword"));

                // Loan approval flag
                session.SetString("enableLoanApprovalsYN", GetXmlTagValueOrDefault(xmlDoc, "enableLoanApprovalsYN", "N"));

                // Load database properties
                using var dbConn = new SqlConnection(strconn);
                dbConn.Open();

                using var cmd = new SqlCommand("SELECT propertyKey, propertyValue FROM accusystemsProperties", dbConn);
                using var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    string key = reader.GetString(0);
                    string value = reader.IsDBNull(1) ? "" : reader.GetString(1);
                    session.SetString(key, value);
                }

                session.SetString("acculoanPropertiesLoaded", "false");

                if (session.GetString("UseBranchSecurity") == "N")
                    session.SetString("bankSecurity", "XX");
                else
                    session.SetString("bankSecurity", session.GetString("acculoan.branchSecurity.level"));
            }
        }

        private string GetXmlTagValue(XmlDocument doc, string tag)
        {
            var node = doc.GetElementsByTagName(tag);
            return node.Count > 0 ? node[0].InnerText.Trim() : null;
        }

        private string GetXmlTagValueOrDefault(XmlDocument doc, string tag, string defaultValue)
        {
            var value = GetXmlTagValue(doc, tag);
            return string.IsNullOrEmpty(value) ? defaultValue : value;
        }

        private string NormalizePath(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return "";

            if (path.StartsWith("\\\\"))
                return path.EndsWith("\\") ? path : path + "\\";
            else
                return path.EndsWith("/") ? path : path + "/";
        }
    }
}
