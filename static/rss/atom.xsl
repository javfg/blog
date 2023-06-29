<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:atom="http://www.w3.org/2005/Atom">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes" />
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
      <head>
        <title>
          RSS Feed | <xsl:value-of select="/atom:feed/atom:title" />
        </title>
        <meta charset="utf-8" />
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="stylesheet" href="style.css" />
      </head>
      <body>
        <header>
          <h1>
            <a href="/" class="title">
              <xsl:value-of select="/atom:feed/atom:title" />
            </a>
          </h1>
          <p>
            <xsl:value-of select="/atom:feed/atom:subtitle" />
          </p>
        </header>
        <section class="rss">
          <aside>
            <strong>This is an RSS feed</strong>. Subscribe by copying the URL from the address bar
            into your newsreader. Visit <a href="https://aboutfeeds.com">About Feeds</a> to learn more
            and get started. It's free.
          </aside>
          <h1>
            <img src="rss/feed-icon.svg" />
            RSS Feed Preview
          </h1>
          <h2>
            <xsl:value-of select="/atom:feed/atom:title" />
          </h2>
          <div class="indented oneliner">
            <p>
              <xsl:value-of select="/atom:feed/atom:subtitle" />
            </p>
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="/atom:feed/atom:link[2]/@href" />
              </xsl:attribute>
            Visit Website &#x2192;
            </a>
          </div>
          <br/>
          <h2>Recent blog posts</h2>
          <ul class="indented">
            <xsl:for-each select="/atom:feed/atom:entry">
              <li class="oneliner">
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="atom:link/@href" />
                  </xsl:attribute>
                  <xsl:value-of select="atom:title" />
                </a>
                <small>
                  <xsl:value-of select="substring(atom:updated, 0, 11)" />
                </small>
              </li>
            </xsl:for-each>
          </ul>
        </section>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
