#!/usr/bin/perl

my @files = <$ARGV[0]*>;
my $ctr = 1;
foreach my $file(@files)
{
  
  open IN,"$file" or die $!;
  my @lines = <IN>;
  open OUT,">$file\.html" or die $!;
  print OUT '   <html><head>
		<title>Domain Architecures</title>
		<meta http-equiv="Content-type" content="text/html;charset=UTF-8">
		<link rel="stylesheet" type="text/css" href="http://web.utk.edu/~oadebali/codost_style.css">
	
		<SCRIPT LANGUAGE="JavaScript"></SCRIPT>
		<script src="http://web.utk.edu/~oadebali/jquery-1.11.0.js"></script>
		<script src="architecturesvg.js"></script>
		<script src="http://cdvist.utk.edu/js/svg-pan-zoom.js"></script>
		<script src="http://web.utk.edu/~oadebali/jquery-ui.js"></script>
	</head>
	 
	 <body link="black">
		<table id="header" border="0">
			<script>document.write(codostmenu());</script>	
				<td class="firstrow" align="right">
				<div class="dropdown"></div>
				</td>
			<script>download_menu();</script>
			</tr></table><table border="0", style=\'table-layout:fixed\'>';
   
  print OUT "@lines";
  print OUT '<script>myreset();stableTopBar();</script>
		<script>
		  (function(i,s,o,g,r,a,m){i[\'GoogleAnalyticsObject\']=r;i[r]=i[r]||function(){
		  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
		  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
		  })(window,document,\'script\',\'//www.google-analytics.com/analytics.js\',\'ga\');

		  ga(\'create\', \'UA-51633352-1\', \'utk.edu\');
		  ga(\'send\', \'pageview\');

		</script>		
		</table>
		
	</body>
</html>
		';
 

$ctr+=1;


}
