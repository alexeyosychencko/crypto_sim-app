import '../models/article.dart';

const List<Article> academyArticles = [
  Article(
    id: 'futures',
    title: 'What Are Futures?',
    summary: 'Learn the basics of futures contracts',
    content: 'Futures are contracts to buy or sell an asset at a future date for a price agreed today. In crypto, futures let you speculate on price movements without owning the actual coin. You profit if your prediction is correct — regardless of whether the price goes up or down.',
    readTimeMinutes: 2,
  ),
  Article(
    id: 'candlestick',
    title: 'How to Read a Candlestick Chart',
    summary: 'Understand candles in 2 minutes',
    content: 'Each candle shows 4 prices: Open, Close, High, Low. A green candle means price went up — close is higher than open. A red candle means price went down. The thin lines (wicks) show the highest and lowest prices reached. Patterns of candles help predict future price direction.',
    readTimeMinutes: 2,
  ),
  Article(
    id: 'long-short',
    title: 'Long vs Short: What\'s the Difference?',
    summary: 'Two directions, double the opportunity',
    content: 'Going Long means you buy expecting the price to rise. You profit when price goes up. Going Short means you sell expecting the price to fall. You profit when price goes down. In futures trading you can do both — this is what makes it powerful compared to simply buying crypto.',
    readTimeMinutes: 2,
  ),
  Article(
    id: 'leverage',
    title: 'Understanding Leverage',
    summary: 'Multiply gains — and risks',
    content: 'Leverage lets you control a larger position with less money. With 10x leverage, $100 controls $1000 worth of crypto. This multiplies both profits and losses. Example: price moves 5% in your favor with 10x leverage — you gain 50%. But if it moves 5% against you — you lose 50%. Always use leverage carefully.',
    readTimeMinutes: 2,
  ),
  Article(
    id: 'risk',
    title: 'Risk Management Basics',
    summary: 'Protect your capital first',
    content: 'Never risk more than 1-2% of your balance on a single trade. Always decide your exit point before entering — both for profit and loss. Lower leverage reduces liquidation risk. Diversify across multiple trades instead of one big bet. Consistent small gains beat occasional big wins over time.',
    readTimeMinutes: 2,
  ),
];
