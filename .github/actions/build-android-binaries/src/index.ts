

import {info, error} from "@actions/core";
import {restoreCache} from "@actions/cache";

export const main = async (args: string[]) => {
  try {
    const [cacheDir, saveKey, ...restoreKeys] = args;
    info(`Restoring to ${cacheDir} with ${[saveKey, ...restoreKeys]}`);
  
    const path = await restoreCache([cacheDir], saveKey, restoreKeys);
    info(`Restored to: ${path}`);
  } catch (err: any) {
    error(err);
  }
}

main(process.argv);
