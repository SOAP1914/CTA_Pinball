"""Virtual test helpers — only loaded via config_virtual_test.yaml."""

from mpf.core.custom_code import CustomCode


class VirtualTestHelper(CustomCode):
    """Keyboard drain helper for smart_virtual testing."""

    def on_load(self):
        self.machine.events.add_handler("test_drain_ball", self._drain)

    def _drain(self, **kwargs):
        del kwargs
        drain = self.machine.ball_devices.items_tagged("drain")[0]
        self.machine.default_platform.add_ball_to_device(drain)
