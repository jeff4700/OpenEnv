import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'OpenEnv', 'src'))

from envs.echo_env import EchoAction, EchoEnv

# Connect to already-running server
echo_env = EchoEnv(base_url="http://localhost:8000")

try:
    result = echo_env.reset()
    print(f"Reset: {result.observation.echoed_message}")
    
    # Send multiple messages
    messages = ["Hello, World!", "Testing echo", "Final message"]
    for msg in messages:
        result = echo_env.step(EchoAction(message=msg))
        print(f"Sent: '{msg}'")
        print(f"  → Echoed: '{result.observation.echoed_message}'")
        print(f"  → Length: {result.observation.message_length}")
        print(f"  → Reward: {result.reward}")
finally:
    echo_env.close()