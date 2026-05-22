import os

# dead code test
def dead_code():
    if False:
        print("This code is never called.")
    pass

class Inventory:
    """
    A simple class to manage a collection of items.
    This class demonstrates a violation of the guideline by returning
    a direct reference to its internal list.
    """
    def __init__(self, initial_items):
        self._items = list(initial_items)

    def get_items(self):
        """
        """
        return self._items

    def __str__(self):
        return f"Inventory contains: {self._items}"

