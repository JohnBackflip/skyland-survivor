# BSP Dungeon Generator
A procedural dungeon generator in Godot that uses Binary Space Partitioning to generate rooms.

Devblog: https://docs.google.com/document/d/14Yw90G5qjx9DQQyEDJYQLiET1Y8Ao1EktQA3I0aUYpE/edit?usp=sharing

# How to use
1. Open bsp_generator.gd
2. Adjust map size, the minimum room size, maximum number of rooms, and optionally the fixed room size, which is only useful if you want to shrink the rooms.
3. The algorithm shrinks each room to a smaller size before connecting them. To get a default BSP style room layout, open bsp_generator.gd and comment out the shrink_rooms() function in _ready().

# Default BSP room layout (For games like The Binding of Isaac)
<img width="412" height="410" alt="image" src="https://github.com/user-attachments/assets/24aeae55-5728-4da0-b004-fddac8fb577a" />

# Rooms & hallways layout (For games like Darkest Dungeon)
<img width="413" height="410" alt="image" src="https://github.com/user-attachments/assets/21b61d7c-caeb-43dd-89c8-b0a934661c7a" />

Note: This algorithm is still incomplete, improvements will be added over time.
