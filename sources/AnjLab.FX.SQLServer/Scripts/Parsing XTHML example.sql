-- Example: Parse XHTML	with getXMLTable
		declare @XMLData1 xml
		set @XMLData1 = '
			<html>
				<head><title>Page title</title></head>
				<body bgcolor = "silver">
					<h1 id = "1">This is test page</h1>
					<hr id = "2"/>
					<div id = "3">
						<p id = "4" name = "first p">This is <b>first </b><u>paragraph</u></p>
						<p id = "5" name = "second p">This is second paragraph.
							<br/>
							<table id = "6" name = "my table" width="300px" border = "1">
								<tr><td align = "center" colspan = "2">This is wide cell</td></tr>
								<tr><td>cell 1.1</td><td>cell 1.2</td></tr>
								<tr><td>cell 2.1</td><td>cell 2.2</td></tr>
							</table>
						</p>
						<ul id = "7">
							<li>For more information visit <a href = "http://anjlab.com" target = "_new">our website</a></li>
							<li>Or AnjLab.FX <a href = "https://github.com/anjlab/fx">repository on GitHub</a></li>
						</ul>
					</div>
				</body>
			</html>'
		exec fx.getXMLTable @XMLData1
