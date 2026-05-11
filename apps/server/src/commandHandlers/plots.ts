const PLOT_UNLOCK_ORDER = [4, 3, 3, 3, 4, 3, 2, 1, 2, 3, 3, 1, 0, 1, 3, 3, 2, 1, 2, 3, 4, 3, 3, 3, 4];

export function getPlotStates(typeValue: string): number[] {
  if (typeValue.length === 0) {
    return PLOT_UNLOCK_ORDER.map((unlockOrder) => {
      if (unlockOrder === 0) {
        return 2;
      }
      if (unlockOrder === 1) {
        return 1;
      }
      return 0;
    });
  }

  return typeValue.split(",").map((value) => Number(value));
}

export function unlockNextPlots(states: number[], boughtIndex: number): void {
  const boughtUnlockOrder = PLOT_UNLOCK_ORDER[boughtIndex];
  if (!Number.isInteger(boughtUnlockOrder)) {
    return;
  }

  const allCurrentPlotsOwned = PLOT_UNLOCK_ORDER.every(
    (unlockOrder, index) => unlockOrder !== boughtUnlockOrder || states[index] === 2
  );
  if (!allCurrentPlotsOwned) {
    return;
  }

  const nextUnlockOrder = boughtUnlockOrder + 1;
  PLOT_UNLOCK_ORDER.forEach((unlockOrder, index) => {
    if (unlockOrder === nextUnlockOrder && states[index] === 0) {
      states[index] = 1;
    }
  });
}
