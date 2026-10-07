enum ShellBackAction {
  popCurrentTab,
  exitSystem,
}

class ShellBackPolicy {
  const ShellBackPolicy._();

  static ShellBackAction resolve({
    required bool currentTabCanPop,
  }) {
    return currentTabCanPop
        ? ShellBackAction.popCurrentTab
        : ShellBackAction.exitSystem;
  }
}
