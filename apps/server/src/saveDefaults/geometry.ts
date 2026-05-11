export function createRectChunk(startX: number, startY: number, width: number, height: number): string[] {
  const tiles: string[] = [];
  for (let y = startY; y < startY + height; y += 1) {
    for (let x = startX; x < startX + width; x += 1) {
      tiles.push(`${x}:${y}`);
    }
  }
  return tiles;
}

export function createHorizontalChunk(startX: number, endX: number, y: number): string[] {
  const tiles: string[] = [];
  for (let x = startX; x <= endX; x += 1) {
    tiles.push(`${x}:${y}`);
  }
  return tiles;
}

export function createVerticalChunk(x: number, startY: number, endY: number): string[] {
  const tiles: string[] = [];
  for (let y = startY; y <= endY; y += 1) {
    tiles.push(`${x}:${y}`);
  }
  return tiles;
}
