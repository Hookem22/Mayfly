<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Let's Eat iPhone App</title>
    <link href="Styles/Style.css" rel="stylesheet" type="text/css" />
    <script src="Scripts/jquery-2.0.3.min.js" type="text/javascript"></script>

    <script type="text/javascript">

        $(document).ready(function () {

            var appBanner = '<meta name="apple-itunes-app" content="app-id=905032020"/>';
            if (document.URL.indexOf("?") > 0) {
                var savedList = document.URL.substr(document.URL.indexOf("?") + 1);
                appBanner = '<meta name="apple-itunes-app" content=\"app-id=905032020, app-argument=letseat://?' + savedList + '\" />';
            }

            $('head').append(appBanner);
        });
        
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <a href="https://itunes.apple.com/us/app/lets-eat/id905032020?ls=1&mt=8"><img style="width: 50%;margin: 0 25%;position: fixed;bottom: 80px;" src="http://www.wiley.com/legacy/wileychi/kassapoglou/images/AppStore.gif"/></a>
    </div>
    </form>
</body>
</html>

