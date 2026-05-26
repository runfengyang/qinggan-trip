// 新疆大环线小红书调研脚本
// 使用 Chrome CDP 抓取搜索结果

const CDPBridge = require(process.env.HOME + '/.npm-global/lib/node_modules/@jackwener/opencli/dist/src/browser/cdp.js').CDPBridge;

const LOCATIONS = [
  { name: '新疆国际大巴扎', day: 'D1' },
  { name: '天山天池', day: 'D2' },
  { name: '五彩滩', day: 'D3' },
  { name: '喀纳斯湖', day: 'D4' },
  { name: '禾木村', day: 'D5' },
  { name: '乌尔禾魔鬼城', day: 'D6' },
  { name: '赛里木湖', day: 'D7' },
  { name: '那拉提草原', day: 'D8' },
  { name: '巴音布鲁克草原', day: 'D9' }
];

async function searchXHS(location) {
  const bridge = new CDPBridge();

  try {
    const page = await bridge.connect({
      cdpEndpoint: 'http://127.0.0.1:9223',
      timeout: 10
    });

    // 导航到搜索结果页
    const searchUrl = `https://www.xiaohongshu.com/search_result?keyword=${encodeURIComponent(location.name)}`;
    await page.send('Page.navigate', { url: searchUrl });

    // 等待页面加载
    await new Promise(r => setTimeout(r, 3000));

    // 获取页面内容
    const result = await page.send('Runtime.evaluate', {
      expression: `
        // 提取搜索结果
        const notes = [];
        const cards = document.querySelectorAll('.note-item, [class*="note"], .search-note-item');
        cards.forEach((card, i) => {
          if (i < 3) {
            const title = card.querySelector('.title, [class*="title"]')?.innerText || '';
            const author = card.querySelector('.author, [class*="author"]')?.innerText || '';
            const likes = card.querySelector('.like-count, [class*="like"]')?.innerText || '';
            const link = card.querySelector('a')?.href || '';
            if (title) {
              notes.push({ title, author, likes, link });
            }
          }
        });
        JSON.stringify(notes);
      `,
      returnByValue: true
    });

    const notes = JSON.parse(result.result.value || '[]');

    await bridge.disconnect();

    return {
      location: location.name,
      day: location.day,
      notes: notes
    };

  } catch (error) {
    console.error(`❌ ${location.name} 搜索失败:`, error.message);
    return {
      location: location.name,
      day: location.day,
      notes: [],
      error: error.message
    };
  }
}

async function main() {
  console.log('🔍 开始新疆大环线小红书调研...\n');

  const results = [];

  for (const location of LOCATIONS) {
    console.log(`📍 ${location.day}: ${location.name}`);
    const result = await searchXHS(location);
    results.push(result);

    if (result.notes.length > 0) {
      console.log(`   ✅ 找到 ${result.notes.length} 条笔记:`);
      result.notes.forEach((note, i) => {
        console.log(`   ${i + 1}. ${note.title.slice(0, 30)}${note.title.length > 30 ? '...' : ''}`);
      });
    } else {
      console.log(`   ⚠️ 未找到笔记`);
    }
    console.log('');

    // 避免请求过快
    await new Promise(r => setTimeout(r, 1000));
  }

  // 保存结果
  const fs = require('fs');
  const outputPath = '/Users/yangrunfeng/web_design/xinjiang-trip/xhs_research.json';
  fs.writeFileSync(outputPath, JSON.stringify(results, null, 2));

  console.log(`\n✅ 调研完成！结果已保存到: ${outputPath}`);
}

main().catch(console.error);
